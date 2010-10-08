module IRB
  class ColoredFormatter < Formatter
    #
    # Terminal escape codes for colors.
    #
    module Color
      COLORS = {
        :nothing      => '0;0',
        :black        => '0;30',
        :red          => '0;31',
        :green        => '0;32',
        :brown        => '0;33',
        :blue         => '0;34',
        :cyan         => '0;36',
        :purple       => '0;35',
        :light_gray   => '0;37',
        :dark_gray    => '1;30',
        :light_red    => '1;31',
        :light_green  => '1;32',
        :yellow       => '1;33',
        :light_blue   => '1;34',
        :light_cyan   => '1;36',
        :light_purple => '1;35',
        :white        => '1;37',
      }
      
      #
      # Return the escape code for a given color.
      #
      def self.escape(name)
        COLORS.key?(name) && "\e[#{COLORS[name]}m"
      end
      
      CLEAR = escape(:nothing)
    end
    
    COLOR_SCHEMES = {
      :default => {
        # :prompt             => :green,
        # :result_prefix      => :light_purple,
        
        # delimiter colors
        :on_comma           => :blue,
        :on_op              => :blue,
        
        # container colors (hash and array)
        :on_lbrace          => :green,
        :on_rbrace          => :green,
        :on_lbracket        => :green,
        :on_rbracket        => :green,
        
        # symbol colors
        :on_ident           => :yellow, # hmm ident...
        :on_symbeg          => :yellow,
        
        # string colors
        :on_tstring_beg     => :red,
        :on_tstring_content => :cyan,
        :on_tstring_end     => :red,
        
        # misc colors
        :on_int             => :cyan,
        :on_kw              => :yellow,
        :on_const           => :light_green
      },
      :fresh => {
        :prompt             => :green,
        :result_prefix      => :light_purple,
        
        :on_comma           => :red,
        :on_op              => :red,
        
        :on_lbrace          => :blue,
        :on_rbrace          => :blue,
        :on_lbracket        => :green,
        :on_rbracket        => :green,
        
        :on_ident           => :yellow,
        :on_symbeg          => :yellow,
        
        :on_int             => :cyan,
        :on_tstring_content => :cyan,
        :on_kw              => :white,
      }
    }
    
    attr_reader :colors, :color_scheme
    
    def initialize
      super
      self.color_scheme = :default
    end
    
    def color_scheme=(scheme)
      @colors = COLOR_SCHEMES[scheme].dup
      @color_scheme = scheme
    end
    
    def colorize_token(type, token)
      if color = colors[type]
        "#{Color.escape(color)}#{token}#{Color::CLEAR}"
      else
        token
      end
    end
    
    def colorize(str)
      Ripper.lex(str).map { |_, type, token| colorize_token(type, token) }.join
    end
    
    def prompt(context)
      colorize_token(:prompt, super)
    end
    
    def result_prefix
      colorize_token(:result_prefix, Formatter::RESULT_PREFIX)
    end
    
    def result(object)
      "#{result_prefix} #{colorize(inspect_object(object))}"
    end
  end
end

IRB.formatter = IRB::ColoredFormatter.new