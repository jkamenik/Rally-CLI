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

terms = ["custom","field"]

class QueryResult
  def query_string
    @query_string
  end
end

des = rally.find(:defect, :order => [:formatted_i_d]){
  _or_ do
    _and_ do
      terms.each do |term|
        contains :description, term
      end
    end
    _and_ do
      terms.each do |term|
        contains :name, term
      end
    end
  end
  
  _or_ do
    lt :schedule_state, 'Completed'
    lt :state, 'Resolved'
  end
}
des.each do |de|
  puts Common.render :de, de
end