#!/usr/local/bin/ruby
require 'rubygems'
require 'rally_rest_api'
require 'date'
require File.dirname(__FILE__)+"/common"

config = Common.load_config
rally = RallyRestAPI.new(
  :username => config[:username],
  :password => config[:password]
)

unless (ARGV.size > 1)
  puts "You must specify at least one Tag"
  exit 1
end

team = ARGV.shift
owners = config["#{team}_team".to_sym] || []


puts 'Tags:'
tags = rally.find(:tag){
  _or_ {
    ARGV.each do |i|
      equal :name, i
    end
  }
}.results
puts "\t#{tags.collect{|t| t.name}.join(", ")}"
puts


puts 'User Stories:'
rally.find(:hierarchical_requirement, :order => [:rank]){
  _or_ {
    tags.each do |i|
      equal :tags, i
    end
  }
  lt :schedule_state, 'Completed'
  _or_ {
    owners.each do |x|
      equal :owner, x
    end
  }
}.each do |us|
  puts Common.render :us, us
end
puts '-'*80

puts 'Defects: '
des = rally.find(:defect, :order => [:priority]){
  _or_ {
    tags.each do |i|
      equal :tags, i
    end
  }
  lt :schedule_state, 'Completed'
  _or_ {
    owners.each do |x|
      equal :owner, x
    end
  }
}.each do |de|
  puts Common.render :de, de
end
puts '-'*80