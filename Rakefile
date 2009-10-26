require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "off_github"
    gem.summary = %Q{Migrate locally installed gems from github to gemcutter.}
    gem.description = %Q{A simple tool which helps migrate your locally installed gems from github to gemcutter. It will find all the gems installed from github and recognize them on gemcutter using some recursive string matching. It will then present you with a list of everything it will migrate and ask for permission before touching anything.}
    gem.email = "max@bitsonnet.com"
    gem.homepage = "http://github.com/maxim/off_github"
    gem.authors = ["Maxim Chernyak"]
    gem.add_dependency "hirb", ">=0.2.4"
    gem.add_development_dependency "shoulda", ">= 0"
    gem.files.include %w(lib/*)
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "html_press #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
