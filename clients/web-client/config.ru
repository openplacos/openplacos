require 'sinatra'
require 'sinatra/content_for'
require 'oauth2'
require 'json'
require File.join(File.dirname(__FILE__),'application.rb')

run WebClient.new
