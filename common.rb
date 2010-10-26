class Common
  class <<self
    def load_config(file="#{ENV['HOME']}/.conf.rb")
      config = {}
      File.open(file) do |f|
        # puts f.readlines.join('')
        config = eval(f.readlines.join(''))
      end
      config
    end
    
    @@escapes ={
      #tags
      "<br[ /]*>" => "\n",
      "</?div[ \\w='\";&-:_]*>" => "",
      "<p[ \\w='\";&-:_]*>" => "",
      "</p>" => "\n",
      "</?span[ \\w='\";&-:_]*>" => "",
      "</?u>" => '',
      # html escapes
      '&gt;' => '>',
      '&lt;' => '<',
      "&nbsp;" => ' '
    }
    
    def escape(string)
      changed = string
      @@escapes.each do |k,v|
        changed = changed.gsub(/#{k}/,v)
      end
      changed
    end
    
    def std_rank(obj)
      obj.rank || '---'
    end
    
    def std_us(us)
      escape "#{std_rank(us)} #{us.formatted_i_d} #{us.schedule_state} #{us.owner} #{us.name}"
    end
    
    def std_ta(ta)
      escape "#{std_rank(ta)} #{ta.formatted_i_d}(#{ta.work_product.formatted_i_d}) #{ta.state} #{ta.owner} #{ta.name}"
    end
    
    def std_de(de)
      escape "#{std_rank(de)} #{de.formatted_i_d} #{de.priority} #{de.schedule_state} #{de.state} #{de.owner}\n\t#{de.name}"
    end
  end
end