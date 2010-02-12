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
  end
end