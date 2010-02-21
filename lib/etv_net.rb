require 'rubygems'

require 'sinatra'
require 'haml'
require 'sinatra/base'

#use Rack::Auth::Basic do |username, password|
#  [username, password] == ['admin', 'admin']
#end

#$LOAD_PATH.unshift File.dirname(__FILE__) + '/domain'

require 'page/page_factory'
require 'page/access_page'
require 'link_info'

require 'cookie_helper'
require 'partial'

require 'open-uri'
require 'json'

class EtvNet < Sinatra::Base
  COOKIE_FILE_NAME = ENV['HOME'] + "/.etvnet-seek"
  
  set :haml, {:format => :html5, :attr_wrapper => '"'}
  set :views, File.dirname(__FILE__) + '/../views'
  set :public, File.dirname(__FILE__) + '/../public'

#  set :data, File.join(File.dirname(__FILE__), *%w[.. data])

  set :sessions, true

  attr_reader :current_page

  def initialize
    @cookie_helper = CookieHelper.new COOKIE_FILE_NAME do
    end
  end

  get '/javascripts/*' do
    open("#{File.dirname(__FILE__)}/../public/javascripts/#{params[:splat]}")
  end

  get '/' do
    haml :index
  end

  get '/login' do
    haml :login
  end

  post "/login" do
    page = LoginPage.new

    cookie = page.login(request[:username], request[:pwd])

    @cookie_helper.save_cookie cookie

    redirect session[:original_path]
  end

  get '/main_menu' do
    page = PageFactory.create("main")

    haml :main_menu, :locals => {:page => page, :title => "Main Menu"}
  end

  get '/best_ten' do
    page = PageFactory.create("best_ten")

    haml :display_items, :locals => {:page => page, :title => "Best Ten"}
  end

  get '/popular_movies_and_serials' do
    page = PageFactory.create("popular")

    haml :display_items, :locals => {:page => page, :title => "Popular Movies and Serials"}
  end

  get '/we_recommend' do
    page = PageFactory.create("we_recommend")

    haml :display_items, :locals => {:page => page, :title => "We Recommend"}
  end

  get '/announces.html' do
    page = PageFactory.create("announces", request.fullpath)

    haml :display_items, :locals => {:page => page, :title => "Announces"}
  end

  get '/freeTV.html' do
    page = PageFactory.create("freetv", request.fullpath)

    haml :display_items, :locals => {:page => page, :title => "Free TV"}
  end

  get '/cgi-bin/video/eitv_browse.fcgi' do
    title = title_for_category params[:category]

    case request.fullpath
      when /category=/ then
        page = PageFactory.create("media", request.fullpath)

        haml :display_items, :locals => {:page => page, :title => title}
      when /action=channels/ then
        page = PageFactory.create("channels", request.fullpath)

        haml :channels, :locals => {:page => page, :title => title}
      when /channel=/ then
        case request.fullpath
          when /action=today/
            title = "Today List"
          else
           title = "Archive List"
        end

        page = PageFactory.create("media", request.fullpath)

        haml :display_items, :locals => {:page => page, :title => title}
    end
  end

  get %r{/action=channels/} do
    page = PageFactory.create("channels")

    haml :display_items, :locals => {:page => page, :title => "Channels"}
  end

  get '/media/*' do
    page = PageFactory.create("media", request.path_info)

    current_item = BrowseMediaItem.new("", request.path_info)

    cookie = @cookie_helper.load_cookie

    if cookie.nil?
      session[:original_path] = request.path_info
      redirect "/login"
    else
      if false #cookie expired?
        @cookie_helper.delete_cookie

        session[:original_path] = request.path_info
        redirect "/login"
      else
        access_page = PageFactory.create("access")

        media_file = params[:splat][0][0..params[:splat][0].index("/")-1]

        media_info = access_page.request_media_info(media_file, cookie)

        if media_info.session_expired?
          @cookie_helper.delete_cookie

          session[:original_path] = request.path_info
          redirect "/login"
        else
          link_info = LinkInfo.new(current_item, media_info)

          haml :media, :locals => {:page => page, :link_info => link_info}
        end
      end
    end
  end

  def title_for_category category
    case category
      when '1P'   then 'Telecasts'
      when '3H'   then 'Movies'
      when '2S'   then 'TV serials'
      when '4D'   then 'Document Movies'
      when '5M'   then 'Kids'
      when '1P4M' then 'Music'
      when '1P3S' then 'Sport'
    else
      ""
    end
  end

  helpers do
    include Partial
  end
end

EtvNet.run! :port => 4567


