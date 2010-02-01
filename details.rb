require 'rubygems'
require 'rally_rest_api'

config = {}
File.open("#{ENV['HOME']}/.conf.rb") do |f|
  # puts f.readlines.join('')
  config = eval(f.readlines.join(''))
end

if(ARGV.count < 1 || ARGV[0].size <= 2)
  puts "Valid ID required"
  exit 1
end

rally = RallyRestAPI.new(
  :username => config[:username],
  :password => config[:password]
)

def print_us(id,rally)
  rally.find(:hierarchical_requirement, :order => [:rank]){
    equal :formatted_i_d, id
  }.each do |us|
    rank = us.rank || '---'
    blocked = us.blocked.size == 4 ? 'blocked' : ''
    puts "#{rank} #{us.formatted_i_d} #{us.name}"
    puts "#{us.schedule_state} #{blocked} #{us.owner}"
    puts "#{us.release} #{us.iteration}"
    puts "Tags: #{us.tags.join(', ')}" if us.tags
    puts "-"*80
    puts us.notes.gsub("<br>","\n").gsub("<br />","\n") if us.notes
    puts "-"*80
    puts us.description.gsub("<br>","\n").gsub("<br />","\n") if us.description
  end
end

def print_ta(id,rally)
  puts "Task"
end

def print_de(id,rally)
  rally.find(:defect, :order => [:rank, :priority]){
    equal :formatted_i_d, id
  }.each do |de|
    rank = de.rank || '---'
    puts "#{rank} #{de.formatted_i_d} #{de.name}"
    puts "#{de.release} #{de.iteration}"
    puts "Prio:#{de.priority}, State:#{de.state}, Owner:#{de.owner}"
    puts "Sev:#{de.severity}, SchState:#{de.schedule_state}, Found:#{de.found_in_build}"
    puts "Tags: #{de.tags.join(', ')}" if de.tags
    puts "-"*80
    puts de.notes.gsub("<br>","\n").gsub("<br />","\n") if de.notes
    puts "-"*80
    puts de.description.gsub("<br>","\n").gsub("<br />","\n") if de.description
  end
end

type = ARGV[0][0..1].downcase

case type
when 'us' then print_us ARGV[0], rally
when 'de' then print_de ARGV[0], rally
when 'ta' then print_ta ARGV[0], rally
else
  puts "Unknown ID type"
  exit 1
end