require 'json'
require 'cgi'

require 'etvnet_seek/core/page'
require 'etvnet_seek/core/media_info'
require 'etvnet_seek/core/service_call'

class AccessPage < ServiceCall
  ACCESS_URL = Page::BASE_URL + "/watch/"

  def initialize
    super(ACCESS_URL)
  end

  def request_media_info media_file, cookie
    params = { 'bitrate' => '2', 'view' => 'submit'}

#    if true
#      params['high_quality'] = ""
#    end
# &other_server=1
    headers = { 'Cookie' => cookie,
                'X-Requested-With' =>	'XMLHttpRequest',
#                'Accept' =>	'application/json, text/javascript, */*',
#                'Accept-Language' =>	'en-us,en;q=0.5',
                #'Accept-Encoding' =>	'gzip,deflate',
#                'Accept-Charset' =>	'ISO-8859-1,utf-8;q=0.7,*;q=0.7',
                'Content-Type' =>	'application/json; charset=UTF-8',
    }

    response = post(params, headers, url + "#{media_file}/")

    # MediaInfo.new Nokogiri::HTML(response.body).css("ref").at(0).attributes["href"].text

    json = JSON.parse(response.body)

    if response.kind_of? Net::HTTPOK
      if json['status'] =~ /error/i
        media_info = MediaInfo.new
        media_info.session_expired = true
        media_info
      else
        MediaInfo.new CGI.unescape(json["url"])
      end
    else
      raise "Problem getting url: #{response.class.name}: #{json['msg']}"
    end
  end

end
