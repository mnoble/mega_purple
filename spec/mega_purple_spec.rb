require File.dirname(__FILE__) + '/spec_helper'

describe MegaPurple do
  
  include SpecHelper
  
  before(:all) do
    stub_ar_columns
  end
  
  it "should be configurable" do
    MegaPurple.configure do |config|
      config.theme = "railscasts"
    end
    MegaPurple.config.theme.should == "railscasts"
  end
  
  it "should allow the user to specify which attribute to highlight" do
    ActiveRecord::Base.respond_to?(:highlight).should be_true
  end
  
  it "should set up a before_save filter to do the highlighting" do
    MegaPurple::Example.new.respond_to?(:purplify).should be_true
  end
  
  it "should parse Textile" do
    example = MegaPurple::Example.new(:body => "__this should be italic__")
    example.purplify(:body).formatted_body.should =~ /<i>this should be italic<\/i>/
  end
  
  it "should not parse Textile if configured that way" do
    example = MegaPurple::NoTextileExample.new(:body => "__this should not be italic__")
    example.purplify(:body)
    example.formatted_body.should == "__this should not be italic__"
  end
  
  it "should convert code blocks into syntax highlighted html" do
    example = MegaPurple::Example.new(:body => 
      "this is some <code lang='ruby_on_rails'>before_save :woot</code> and 
      <code>def some; other; end</code> stuff"
    )
    example.purplify(:body)
    example.formatted_body.should =~ /<pre class="railscasts">/
  end
  
end