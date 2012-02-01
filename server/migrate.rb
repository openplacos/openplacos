#!/usr/bin/ruby

require "active_record"

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "test.db", :pool => 25)
ActiveRecord::Migrator.migrate('db')
