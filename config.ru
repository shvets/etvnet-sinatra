require "lib/app"

trap(:INT) { exit }

app = Rack::Builder.new {
 use Rack::CommonLogger
 use App
}.to_app

run app


