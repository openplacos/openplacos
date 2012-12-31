source "http://rubygems.org"

gem "serialport", "~> 1.0.4"
gem "micro-optparse", "~> 1.1.5"
gem "choice", "~> 0.1.4"
gem "file-find", "~> 0.3.5"

gem "ruby-dbus-openplacos", "~> 0.7.0"
gem "rb-pid-controller", "~> 0.0.1", :git => 'git://github.com/flagos/rb-pid-controller'
gem "pidfile", "~> 0.3.0"

# for webserver
group :webserver do
  gem 'oauth2-provider', :require => 'oauth2/provider', :git => 'git://github.com/songkick/oauth2-provider'
  gem "activerecord"
  gem 'sqlite3'
  gem 'sinatra', "~> 1.3.2"
  gem 'thin', "~> 1.3.1"
  gem 'haml'
  gem 'sinatra-content-for'
end

#for clients
group :clients do
  gem "openplacos", "~> 0.0.9"
  gem "micro-optparse", "~> 1.1.5"
end

group :cliclient do
  gem "rink"
  gem "highline"
end

group :webclient do
  gem "sinatra", "~> 1.3.2"
  gem "sinatra-contrib", "~> 1.3.1"
  gem "thin", "~> 1.3.1"
  gem 'haml'
end

# for testing
gem 'rspec'
