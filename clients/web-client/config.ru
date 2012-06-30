require 'sinatra'
require 'sinatra/content_for'
require 'oauth2'
require 'json'
require 'micro-optparse'
require "openplacos/libclient"

THIS_FILE = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__

require File.join(File.dirname(THIS_FILE),'application.rb')

Connect.instance.init
run WebClient.new
