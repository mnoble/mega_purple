$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib/')
require 'active_record'
require 'uv'
require File.dirname(__FILE__) + '/../init'

module MegaPurple
  class Example < ActiveRecord::Base
    highlight :body
  end
  class NoTextileExample < ActiveRecord::Base
    highlight :body, :textile => false
  end
end

module SpecHelper
  def stub_ar_columns
    stub_columns(MegaPurple::Example)
    stub_columns(MegaPurple::NoTextileExample)
  end
  
  def stub_columns(klass)
    column = ActiveRecord::ConnectionAdapters::Column
    klass.stub!(:columns).and_return([
      column.new("body", nil, "string", false),
      column.new("formatted_body", nil, "string", false)
    ])
  end
end