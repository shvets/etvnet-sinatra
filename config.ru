require "lib/app"

trap(:INT) { exit }

app = Rack::Builder.new {
 use Rack::CommonLogger
 run App
}.to_app

run app


