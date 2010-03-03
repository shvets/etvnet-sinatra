require 'lib/app'

Rack::Handler::Mongrel.run App.new, :Port => 4567