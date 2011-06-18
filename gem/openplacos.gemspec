# -*- ruby -*-
require "rubygems"
require "rake"

GEMSPEC = Gem::Specification.new do |s|
  s.name = "openplacos"
  s.summary = "Openplacos libraries : Libclient, LibPlugin, LibDriver"
  s.description = <<-EOF
    Openplacos Gem is a set of libraries for openplacos software.
    These libraries allow an easier coding of openplacos clients, plugins or drivers in ruby.
  EOF
  s.version = File.read("VERSION").strip
  s.license = 'GPL-3'
  s.author = "Openplacos Team"
  s.email = "openplacos@lists.tuxfamily.org"
  s.homepage = "http://openplacos.tuxfamily.org/"
  s.files = FileList["{lib}/**/*", "openplacos.gemspec", "VERSION"].to_a.sort
  s.require_path = "lib"
  s.has_rdoc = false
  s.add_dependency('ruby-dbus-openplacos', '>= 0.6.2')
end
