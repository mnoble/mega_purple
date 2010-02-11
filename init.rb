require 'uv'
require 'redcloth'
require 'mega_purple'

Uv.init_syntaxes
MegaPurple.configure
ActiveRecord::Base.send(:extend, MegaPurple::ClassMethods)