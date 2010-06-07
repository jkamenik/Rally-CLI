#!/usr/local/bin/ruby
require 'rubygems'
require 'rally_rest_api'
require 'date'
require File.dirname(__FILE__)+"/common"

class CloseDE
  def initialize
    config = Common.load_config
    @rally = RallyRestAPI.new(
      :username => config[:username],
      :password => config[:password]
    )
    
    @states = ['Submitted','Open','Fixed','Closed']
    @schedule_states = ['Defined','In-Progress','Completed','Accepted']
    @resolutions = ['Code Change','Architecture','Configuration Change','Database Change','Duplicate','Need More Information','Cannot Reproduce','Not a Defect','Software Limitation','User Interface','User Interface','Will Not Fix','Obsoleted','Converted']
  
    @changes = {
      :state => @states[2], #default fixed
      :schedule_state => @schedule_states[2], #default Complete
      :resolution => @resolutions[0],
      :fixed_in_build => Time.now.strftime("%Y-%m-%d")
    }
    @de = nil
    @append_note = true
    @append_release_note = true
  end

  def usage
    puts "close_de [<options>] <DE_ID> [<note>]"
    puts
    puts "Options"
    puts "  -a <hours>: Set the actual hours worked"
    puts "  -f <fixed_in>: Set the time of the fix.  Defaults to now: #{@changes[:fixed_in_build]}"
    puts "  -n <note>: Text to append to the notes field."
    puts "  -N <note>: Set the note field erasing anything that is already there."
    puts "  -r <release_note>: Text to append to the release notes field"
    puts "  -R <release_note>: Set the release note erasing anything that is already there."
    puts "  -s <N>: Sets state to:"
    @states.each_with_index {|s,i| puts "    #{i}: #{s}#{i == 2 ? ' (default)' : ''}"; }
    puts "  -S <N>: Set scheduled state to:"
    @schedule_states.each_with_index {|s,i| puts "    #{i}: #{s}#{i == 2 ? ' (default)' : ''}"; }
    puts "  -X <N>: Sets the resolution to:"
    @resolutions.each_with_index {|s,i| puts "    #{i}: #{s}#{i == 0 ? ' (default)' : ''}"; }
    puts "  --leave: leaves the state, schedule_state, and resolution alone."
    puts "  --invalid: Sets state to '#{@states[3]}', schedule state to '#{@schedule_states[3]}', and resolution to '#{@resolutions[7]}'"
    puts
    puts "Note"
    puts "The notes field can either be specified via -n, -N, or by collecting the remaining command line text after args are processed.  If -n, or -N are passed then the extra texted is not processed.  If both -n and -N are passed then the last one wins."
    puts
    puts "Examples:"
    puts "close_de.rb DE100 --invalid"
    puts "  Invalidates the DE without providing any explaination"
    puts
    puts "close_de.rb DE100 -R 'Things are better now' This will be the note"
    puts "  Closes DE100 with the release text 'Things are better now' and the note 'This will the note'"
    puts
    puts 'close_de.rb DE100 --leave -n "appended text"'
    puts "  Leave DE100 in the same state, and appends:"
    puts "  "+'-'*20
    puts "  appended text"
  end
  
  def process_args(arguments)
    mark = match = false
    unknown_args = []
    ARGV.each_with_index do |arg,i|
      match = false
      if mark
        mark = false
        next
      end

      case arg
      when '?', '-h' then usage; exit(1)
      when '-s' then @changes[:state] = @states[ARGV[i+1].to_i]; match = mark = true
      when '-S' then @changes[:schedule_state] = @schedule_states[ARGV[i+1].to_i]; match = mark = true
      when '-f' then @changes[:fixed_in_build] = ARGV[i+1]; match = mark = true
      when '-a' then @changes[:actual_hours] = ARGV[i+1]; match = mark = true
      when '-r' then @changes[:release_note_text] = ARGV[i+1]; @append_release_note = true; match = mark = true
      when '-R' then @changes[:release_note_text] = ARGV[i+1]; @append_release_note = false; match = mark = true
      when '-n' then @changes[:notes] = ARGV[i+1]; @append_note = true; match = mark = true
      when '-N' then @changes[:notes] = ARGV[i+1]; @append_note = false; match = mark = true

      # special marks
      when '--invalid' then
        @changes[:state] = @states[3]
        @changes[:schedule_state] = @schedule_states[3]
        @changes[:resolution] = @resolutions[7]
        match = true
      when '--leave' then
        del @changes[:state]
        del @changes[:schedule_state]
        del @changes[:resolution]
        match = true
      end

      unknown_args.push arg if !match
    end

    if unknown_args.size > 0
      @de = unknown_args.shift
      @changes[:notes] = unknown_args.join(' ') unless @note
    end
    
    @de = @de.slice(/[0-9]+/)
    
    # puts "de: #{@de}"
    # puts "append note: #{@append_note}"
    # puts "append release note: #{@append_release_note}"
    # @changes.each do |k,v|
    #   puts "#{k}: #{v}"
    # end
  end
  
  def run(args)
    process_args args
    
    unless @de
      puts "DE is needed"
      usage
      exit(1)
    end
    
    unless @note
      puts "Warning: No note given"
    end
    
    get_de
    
    set_de
  end
  
  def get_de
    x = @de.to_i #stupid, but I need to copy so rally can read it properly
    des = @rally.find(:defect,{:pagesize => 1}){
      equal :formatted_i_d, x
    }
    @real_de = des.first
    
    if !@real_de
      puts "No DE found"
      exit(1)
    end
  end
  
  def set_de
    if @append_note && @changes.has_key?(:notes) && !@real_de.notes.nil?
      @changes[:notes] = "#{@real_de.notes}\n#{'-'*80}\n#{@changes[:notes]}"
    end
    if @append_release_note && @changes.has_key?(:release_note_text) && !@real_de.release_note_text.nil?
      @changes[:release_note_text] = "#{@real_de.release_note_text}\n#{'-'*80}\n#{@changes[:release_note_text]}"
    end
    
    print_changes
    
    @real_de.update @changes
  end
  
  def print_changes
    obj = @real_de.to_hash
    @changes.each do |k,v|
      if obj[k] != v
        puts k.to_s.upcase
        puts "Original: #{obj[k]}"
        puts "New #{v.class}: #{v}"
        puts
      end
    end
  end
end

x = CloseDE.new
x.run(ARGV)