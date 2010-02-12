require 'rubygems'
require 'rally_rest_api'
require 'date'
require File.dirname(__FILE__)+"/common"

config = Common.load_config
# File.open("#{ENV['HOME']}/.conf.rb") do |f|
#   # puts f.readlines.join('')
#   config = eval(f.readlines.join(''))
# end
team = ARGV[0] || 'my'
owners = config["#{team}_team".to_sym] || []
puts owners

rally = RallyRestAPI.new(
  :username => config[:username],
  :password => config[:password]
)

now = Time.now.strftime("%Y-%m-%d")
iterations = rally.find(:iteration){
  _or_ {
    equal :state, 'Committed'
    _and_ {
      lte :start_date, now
      gte :end_date, now
    }
  }
}.results
iterations.each do |i|
  start_date = Date.parse(i.start_date)
  end_date   = Date.parse(i.end_date)
  puts "#{i.name}: #{start_date} - #{end_date}"
  puts "#{i.theme}" if i.theme
end
puts '-'*80

puts 'User Stories:'
rally.find(:hierarchical_requirement, :order => [:rank]){
  _or_ {
    iterations.each do |i|
      equal :iteration, i
    end
  }
  lt :schedule_state, 'Completed'
  _or_ {
    owners.each do |x|
      equal :owner, x
    end
  }
}.each do |us|
  rank = us.rank || '---'
  puts "#{rank} #{us.formatted_i_d} #{us.schedule_state} #{us.owner} #{us.name}"
end
puts '-'*80

puts 'Defects: '
des = rally.find(:defect, :order => [:rank, :priority]){
  _or_ {
    iterations.each do |i|
      equal :iteration, i
    end
  }
  _or_{
    lt :schedule_state, 'Completed'
    lt :state, 'Fixed'
  }
  _or_ {
    owners.each do |x|
      equal :owner, x
    end
  }
}.each do |de|
  rank = de.rank || '---'
  puts "#{rank} #{de.formatted_i_d} #{de.priority} #{de.schedule_state} #{de.state} #{de.owner}"
  puts "\t#{de.name}"
end
puts '-'*80

puts 'Tasks:'
rally.find(:task, :order => :rank){
  _or_ {
    iterations.each do |i|
      equal :iteration, i
    end
  }
  lt :state, 'Completed'
  _or_ {
    owners.each do |x|
      equal :owner, x
    end
  }
}.each do |ta|
  rank = ta.rank || '---'
  puts ' '*20+'-'*40+' '*20
  puts "#{rank} #{ta.formatted_i_d}(#{ta.work_product.formatted_i_d}) #{ta.state} #{ta.owner} #{ta.name}"
  puts Common.escape(ta.description) if ta.description
end
puts '-'*80