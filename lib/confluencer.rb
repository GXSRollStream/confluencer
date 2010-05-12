# ensure that lib is in the load path
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'log4r'

require 'confluence/error'

require 'confluence/client'
require 'confluence/session'

require 'confluence/findable'
require 'confluence/record'
require 'confluence/space'
require 'confluence/page'
require 'confluence/bookmark'
require 'confluence/blog_entry'

module Confluencer
  VERSION = "0.2.7"
end
