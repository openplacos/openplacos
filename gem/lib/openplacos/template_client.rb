#!/usr/bin/ruby


require 'digest/sha1'
require File.dirname(__FILE__) + "/libclient_oauth.rb"

HOST = 'http://0.0.0.0:4567'     
REDIRECT_URI = "http://0.0.0.0:2000"
ID = Digest::SHA1.file(__FILE__).hexdigest



client = Openplacos::Client.new(HOST, "TRUC", ["read", "user"] , "auth_code")

puts client.proxyobjects["/home/temperature"]["analog.sensor.temperature.celcuis"].read({})

