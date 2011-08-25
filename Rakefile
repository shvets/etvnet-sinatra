require 'rake'
require 'rspec/core/rake_task'

begin
  require 'zipit'
rescue LoadError
  puts "Zipit is not available. Install it with: sudo gem install zipit"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "etvnet"
    gemspec.summary = "Sinatra application for ETVNet web site and command line application."
    gemspec.description = "Sinatra application for ETVNet web site and command line application."
    gemspec.email = "alexander.shvets@gmail.com"
    gemspec.homepage = "http://github.com/shvets/etvnet"
    gemspec.authors = ["Alexander Shvets"]
    gemspec.files = FileList["CHANGES", "etvnet.gemspec", "Rakefile", "config.ru", "Gemfile", "README", "VERSION", "lib/**/*", 
                             "bin/**", "spec/**", "public/**", "views/**",  "views/shared/**"]
    gemspec.add_dependency("json_pure", ">= 1.2.0")
    gemspec.add_dependency("highline", ">= 1.5.1")
    gemspec.add_dependency("libxml-ruby", ">= 1.1.3")
    gemspec.add_dependency("nokogiri", ">= 1.4.1")

    gemspec.add_development_dependency "rspec", ">= 1.2.9"
    gemspec.add_development_dependency "mocha", ">= 0.9.7"

    gemspec.executables = ['etvnet', 'etvnet-seek']
    gemspec.requirements = ["none"]
    gemspec.bindir = "bin"
  end
rescue LoadError
  puts "Jeweler not available. Install it for jeweler-related tasks with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end

task :zip do
  zip :archive => "etvnet-seek.zip", :dir => "."
end

desc "Release the gem"
task :"release:gem" do
  %x(
      rm -rf pkg
      rake gemspec
      rake build
      rake install
      git add .
  )
  puts "Commit message:"
  message = STDIN.gets

  version = "#{File.open(File::dirname(__FILE__) + "/VERSION").readlines().first}"

  %x(
    git commit -m "#{message}"

    git push origin master

    gem push pkg/#{File.basename(File.expand_path("."))}-#{version}.gem
  )
end

desc "Run gem code locally"
task :"run:gem" do
  command = "bin/etvnet-seek"
  puts ruby("#{command}")
end

# configure rspec
RSpec::Core::RakeTask.new do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.verbose = false
end

task :default => :zip