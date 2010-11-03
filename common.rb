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
    
    @@rally_types = {
      :tags => :tag,
      :ta   => :task,
      :tas  => :task,
      :de   => :defect,
      :des  => :defect,
      :us   => :hierarchical_requirement
    }
    
    @@escapes ={
      #tags
      "<br[ /]*>"                => "\n",
      "<div[ \\w='\";&-:_]*>"    => "",
      "</div>"                   => "\n",
      "<p[ \\w='\";&-:_]*>"      => "",
      "</p>"                     => "\n",
      "</?span[ \\w='\";&-:_]*>" => "",
      "</?u>"                    => '',
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
    
    def std_tags(obj,prefix='',postfix="\n")
      "#{prefix}#{obj.tags.join(', ')}#{postfix}" if obj.tags.size > 0
    end
    
    def std_rank(obj)
      obj.rank || '---'
    end
    
    def std_hierarchical_requirement(us)
      escape "#{std_rank(us)} #{us.formatted_i_d} #{us.schedule_state} #{us.owner} #{us.name}"
    end
    
    def std_task(ta)
      escape "#{std_rank(ta)} #{ta.formatted_i_d}(#{ta.work_product.formatted_i_d}) #{ta.state} #{ta.owner} #{ta.name}"
    end
    
    def std_defect(de)
      str =  escape "#{std_rank(de)} #{de.formatted_i_d} #{de.priority} #{de.schedule_state} #{de.state} #{de.owner}\n"
      str += std_tags(de,"\t")
      str += "\t#{de.name}"
    end
    
    def std_tag(tag)
      escape tag.name
    end
    
    def rally_type(type)
      @@rally_types[type.to_sym] || type
    end
    
    def can_render?(type)
      self.respond_to? "std_#{rally_type(type)}"
    end
    
    def render(type,obj)
      Common.send("std_#{rally_type(type)}".to_sym,obj) if can_render?(type)
    end
  end
end