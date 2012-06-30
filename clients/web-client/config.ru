require "bundler"
Bundler.setup(:clients, :webclient)

require "openplacos/libclient"
require 'sinatra'
require 'sinatra/content_for'
require "openplacos/libclient"
require 'micro-optparse'

THIS_FILE = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__

require File.join(File.dirname(THIS_FILE),'application.rb')

Connect.instance.init
run WebClient.new
