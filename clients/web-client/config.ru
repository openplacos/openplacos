require 'sinatra'
require 'sinatra/content_for'
require './application.rb'


run WebClient.new
