require 'rubygems' unless RUBY_VERSION =~ /1.9.*/

$:.unshift(File::join(File::dirname(File::dirname(__FILE__)), "lib"))

require 'etvnet_seek/etvnet_seek'

#
#trap(:INT) { exit }
#
#app = Rack::Builder.new {
# use Rack::CommonLogger
# run App
#}.to_app
#
#run app


# To use with thin
#  thin start -p PORT -R config.ru
require File.join(File.dirname(__FILE__), 'lib', 'etvnet')

trap(:INT) { exit }

app = Rack::Builder.new {
 use Rack::CommonLogger
 run Etvnet::App
}.to_app

run app

if ENV['launchy']
  require 'launchy'

  Launchy::Browser.run("http://localhost:9292")
end

