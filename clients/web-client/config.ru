require 'sinatra'
require 'sinatra/content_for'
require 'oauth2'
require 'json'
require 'micro-optparse'
require File.join(File.dirname(__FILE__),'/../../gem/lib/openplacos/libclient.rb')
require File.join(File.dirname(__FILE__),'application.rb')


Connect.instance.init
run WebClient.new
