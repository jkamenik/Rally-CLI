#!/usr/local/bin/ruby
require 'rubygems'
require 'rally_rest_api'
require 'date'
require File.dirname(__FILE__)+"/common"

config = Common.load_config
type = ARGV[0].to_sym

rally = RallyRestAPI.new(
  :username => config[:username],
  :password => config[:password]
)

ARGV.each do |arg|
  type = arg[0..1].downcase.to_sym
  
  rally.find(Common.rally_type(type)){ equal :formatted_i_d, arg }.each do |x|
    changes = {
      :schedule_state => 'In-Progress',
      :owner          => config[:username]
    }
    
    x.update changes
  end
end