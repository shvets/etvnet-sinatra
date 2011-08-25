#require 'open-uri'
#
#require 'net/http'

require 'mechanize'

# Lengthen timeout in Net::HTTP
#module Net
#  class HTTP
#    alias old_initialize initialize
#
#    def initialize(*args)
#      old_initialize(*args)
#      @read_timeout = 3*60 # 3 minutes
#    end
#  end
#end

class ServiceCall2
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def get
    #open(url, "User-Agent" => "Ruby/#{RUBY_VERSION}")
    agent = Mechanize.new
    #{ |a| a.log = Logger.new(STDERR) }
    agent.user_agent = 'Ruby/#{RUBY_VERSION}'
    #agent.user_agent_alias = 'Linux Mozilla'
    agent.open_timeout = 3
    agent.read_timeout = 4
    agent.keep_alive = false

    agent.get(url).body
  end

  def post params, headers, url = @url
#    headers = { 'X-Requested-With' => 'XMLHttpRequest', 'Content-Type' => 'application/json; charset=utf-8', 'Accept' => 'application/json, text/javascript, */*'}

#    request = Net::HTTP::Post.new(url, headers.merge({"User-Agent" => "Ruby/#{RUBY_VERSION}"}))
#    request.set_form_data(params)
#    #request.basic_auth(un, pw)
#    #"Content-Type"=>"application/x-www-form-urlencoded",
#    #"Authorization" => "Basic " + Base64::encode64("account:password")
#    response = request(request, url)
#
#    if response.class == Net::HTTPMovedPermanently
#      response = handle_redirect response['location'], params, headers
#    end
#
#    response

    agent = Mechanize.new
    agent.pre_connect_hooks << lambda { |p|
      p[:request]['X-Requested-With'] = 'XMLHttpRequest'
      p[:request]['User-Agent'] = "Ruby/#{RUBY_VERSION}"
    }

    #{ |a| a.log = Logger.new(STDERR) }
    agent.user_agent = 'Ruby/#{RUBY_VERSION}'
    #agent.user_agent_alias = 'Linux Mozilla'
#    agent.open_timeout = 3*60
#    agent.read_timeout = 4*60
#    agent.keep_alive = false

    page = agent.post(url, params, headers.merge({"User-Agent" => "Ruby/#{RUBY_VERSION}"}))
    p page
  end

  protected

#  def handle_redirect url, params, headers
#    request = Net::HTTP::Post.new(url, headers.merge({"User-Agent" => "Ruby/#{RUBY_VERSION}"}))
#    request.set_form_data(params)
#
#    request(request, url)
#  end

#  def request request, url
#    uri = URI.parse(url)
#
#    connection = Net::HTTP.new(uri.host, uri.port)
#
#    connection.request(request)
#  end

end