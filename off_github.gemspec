# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{off_github}
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Maxim Chernyak"]
  s.date = %q{2009-11-04}
  s.default_executable = %q{off_github}
  s.description = %q{A simple tool which helps migrate your locally installed gems from github to gemcutter. It will find all the gems installed from github and recognize them on gemcutter using some recursive string matching. It will then present you with a list of everything it will migrate and ask for permission before touching anything.}
  s.email = %q{max@bitsonnet.com}
  s.executables = ["off_github"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/off_github",
     "lib/off_github.rb",
     "lib/off_github.rb",
     "off_github.gemspec",
     "test/helper.rb",
     "test/test_off_github.rb"
  ]
  s.homepage = %q{http://github.com/maxim/off_github}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Migrate locally installed gems from github to gemcutter.}
  s.test_files = [
    "test/helper.rb",
     "test/test_off_github.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hirb>, [">= 0.2.4"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
    else
      s.add_dependency(%q<hirb>, [">= 0.2.4"])
      s.add_dependency(%q<shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<hirb>, [">= 0.2.4"])
    s.add_dependency(%q<shoulda>, [">= 0"])
  end
end

