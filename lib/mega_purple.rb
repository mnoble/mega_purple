module MegaPurple
  # Configure the default options for Ultraviolet.
  #
  # * <tt>theme</tt> - String specifying the Ultraviolet theme to use
  # * <tt>line_numbers</tt> - Boolean, true for line numbers, false for none
  # * <tt>lang</tt> - String specifying the language to use, ie: "ruby", "css", etc.
  #
  # Best way to set MegaPurple up is to add <tt>config/initializers/megapurple.rb</tt>
  # file with the following in it:
  #
  #   MegaPurple.configure do |config|
  #     config.theme = "railscasts"
  #     config.line_numbers = true
  #     config.lang = "ruby_on_rails"
  #   end
  #
  def self.configure
    @config ||= Config.new
    yield @config if block_given?
  end
  
  def self.config
    @config
  end
  
  class Config #:nodoc:
    attr_accessor :theme, :line_numbers, :lang
    def initialize
      @theme, @line_numbers, @lang = "twilight", false, "ruby"
    end
  end
  
  # Proxy class used for the <tt>before_save</tt> so the attribute
  # can be directly sent to the method.
  class Purpler
    def initialize(attribute)
      @attribute = attribute
    end
    
    def before_save(record)
      record.send(:purplify, @attribute)
    end
  end
  
  
  module ClassMethods
    # Specifies which attribute should be run through the
    # syntax highlighter.
    #
    #   class Person < ActiveRecord::Base
    #     highlight :body
    #   end
    #
    def highlight(attribute, options={})
      class << self; attr_accessor :mp_options; end
      @mp_options = { :textile => true }.merge(options)
      
      before_save MegaPurple::Purpler.new(attribute)
      include MegaPurple::InstanceMethods
    end
  end
  
  
  module InstanceMethods
    def purplify(attribute)
      text = parse(send(attribute))
      send("formatted_#{attribute}=", text)
      self
    end
    
    # Seperates the text into regular text and code blocks.
    # Converts regular text to Textile, via RedCloth, and 
    # syntax highlighted hotness, via Ultraviolet.
    #
    def parse(text)
      text.split(/(<code.*?>.*?<\/code>)/m).inject("") do |result, piece|
        if piece =~ /^<code/
          result << highlight(piece.gsub(/<code.*?>|<\/code>/, ""), parse_lang(piece)).chomp
        else
          result << format(piece)
        end
      end
    end
  
  private
    
    def parse_lang(code)
      code.scan(/<code(?:\s+lang=(?:"|'))(.*?)(?:"|')>/).flatten.first
    end
    
    def highlight(code, lang)
      language = lang.nil? ? options.lang : lang
      Uv.parse(code, "xhtml", language, options.line_numbers, options.theme)
    end
    
    def format(text)
      if self.class.mp_options[:textile]
        RedCloth.new(text.strip).to_html
      else
        text.gsub("\r", "").gsub("\n", "<br/>")
      end
    end
    
    def options
      MegaPurple.config
    end
    
  end
end