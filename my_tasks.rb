require 'rally_rest_api'
require 'date'

config = {}
File.open("#{ENV['HOME']}/.conf.rb") do |f|
  # puts f.readlines.join('')
  config = eval(f.readlines.join(''))
end

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
  equal :owner, config[:self]
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
  equal :owner, config[:self]
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
  equal :owner, config[:self]
}.each do |ta|
  rank = ta.rank || '---'
  puts "#{rank} #{ta.formatted_i_d}(#{ta.work_product.formatted_i_d}) #{ta.state} #{ta.owner} #{ta.name}"
  puts "\t#{ta.description}" if ta.description
end
puts '-'*80