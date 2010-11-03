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

unless (ARGV.size >= 2)
  puts "You must specify a team and a schedule state"
  exit 1
end

team   = ARGV.shift
state  = ARGV.shift
owners = config["#{team}_team".to_sym] || []


[:de,:us].each do |type|
  rally.find(Common.rally_type(type)) do
    equal :schedule_state, state
    _or_ {
      owners.each do |x|
        equal :owner, x
      end
    }
  end.each do |x|
    puts Common.render(type.to_sym,x)
  end
end