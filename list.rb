require 'rubygems'
require 'rally_rest_api'
require 'date'
require File.dirname(__FILE__)+"/common"

config = Common.load_config
# File.open("#{ENV['HOME']}/.conf.rb") do |f|
#   # puts f.readlines.join('')
#   config = eval(f.readlines.join(''))
# end
type = ARGV[0].to_sym

unless Common.can_render? type
  puts "Cannot list #{type} items"
  exit 1
end

rally = RallyRestAPI.new(
  :username => config[:username],
  :password => config[:password]
)

rally.find_all(Common.rally_type(type)).each do |x|
  puts Common.render(type,x)
end