require "lib/app"

trap(:INT) { exit }

app = Rack::Builder.new {
 use Rack::CommonLogger
 run App
}.to_app

Rack::Handler::Mongrel.run app, :Port => 4567



