#!/usr/bin/ruby



require File.dirname(__FILE__) + "/libclient_oauth.rb"

HOST = 'http://0.0.0.0:4567'     
REDIRECT_URI = "http://0.0.0.0:2000"



Openplacos::Client.new(HOST, "TRUC", ["read", "user"] , "auth_code")
