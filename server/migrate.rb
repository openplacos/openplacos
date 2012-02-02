#!/usr/bin/ruby

require "rubygems"
require "active_record"
require "oauth2/provider"

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "test.db", :pool => 25)
ActiveRecord::Migrator.migrate('db')
