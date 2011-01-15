# -*- ruby -*-
require "rubygems"
require "rake"

GEMSPEC = Gem::Specification.new do |s|
  s.name = "openplacos"
  # s.rubyforge_project = nil
  s.summary = "Openplacos libraries : Libclient, LibPlugin, LibDriver"
  # s.description = FIXME
  s.version = File.read("VERSION").strip
  s.author = "Openplacos Team"
  s.email = "openplacos-general@lists.sourceforge.net"
  s.homepage = "http://openplacos.sourceforge.net/"
  s.files = FileList["{lib}/**/*", "Rakefile", "openplacos.gemspec", "VERSION"].to_a.sort
  s.require_path = "lib"
  s.has_rdoc = false
end
