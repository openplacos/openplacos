# -*- ruby -*-
require "rubygems"
require "rake"

GEMSPEC = Gem::Specification.new do |s|
  s.name = "openplacos"
  # s.rubyforge_project = nil
  s.summary = "Openplacos libraries : Libclient, LibPlugin, LibDriver"
  s.description = <<-EOF
    Openplacos Gem is a set of libraries for openplacos software.
    These libraries allow an easier coding of openplacos clients, plugins or drivers in ruby.
  EOF
  s.version = File.read("VERSION").strip
  s.author = "Openplacos Team"
  s.email = "openplacos-general@lists.sourceforge.net"
  s.homepage = "http://openplacos.sourceforge.net/"
  s.files = FileList["{lib}/**/*", "openplacos.gemspec", "VERSION"].to_a.sort
  s.require_path = "lib"
  s.has_rdoc = false
  s.add_dependency('ruby-dbus', '>= 0.6.0')
end
