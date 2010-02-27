require 'rubygems'

require 'sinatra'
require 'sinatra/base'
require 'haml'
require 'open-uri'
require 'json'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

require 'page/page_factory'
require 'page/access_page'
require 'link_info'
require 'cookie_helper'

require 'partial'

class App < Sinatra::Base
  COOKIE_FILE_NAME = ENV['HOME'] + "/.etvnet-seek"
  
  set :haml, {:format => :html5, :attr_wrapper => '"'}
  set :views, File.dirname(__FILE__) + '/../views'
  set :public, File.dirname(__FILE__) + '/../public'
  set :sessions, true

  def initialize
    @cookie_helper = CookieHelper.new COOKIE_FILE_NAME
  end

  get '/javascripts/*' do
    open("#{File.dirname(__FILE__)}/../public/javascripts/#{params[:splat]}")
  end

  get '/' do
    main_page = PageFactory.create("main")
    best_ten_page = PageFactory.create("best_ten")
    popular_page = PageFactory.create("popular")
    we_recommend_page = PageFactory.create("we_recommend")

    haml :index, :locals => {:main_page => main_page, :best_ten_page => best_ten_page,
                             :popular_page => popular_page, :we_recommend_page => we_recommend_page}
  end

  get '/login' do
    haml :login
  end

  post "/login" do
    page = PageFactory.create("login")

    cookie = page.login(request[:username], request[:pwd])

    @cookie_helper.save_cookie cookie

    redirect session[:original_path]
  end

  get '/announces.html' do
    page = PageFactory.create("announces")

    haml :display_items, :locals => {:page => page, :title => "Announces"}
  end

  get '/freeTV.html' do
    page = PageFactory.create("freetv")

    haml :display_items, :locals => {:page => page, :title => "Free TV"}
  end

  get '/cgi-bin/video/eitv_browse.fcgi' do
    url = request.fullpath

    title = title_for_category params[:category]

    case url
      when /(category=|channel=)/ then
       case url
          when /action=today/
            title = "Today List" + (title.nil? ? "" : ": #{title}")
          else
            title = "Archive List" + (title.nil? ? "" : ": #{title}")
        end

        page = PageFactory.create("media", url)

        haml :display_browse_items, :locals => {:page => page, :title => title}
      when /action=channels/ then
        page = PageFactory.create("channels", url)

        haml :display_channel_items, :locals => {:page => page, :title => title}
      when /action=view_recommended/ then
        page = PageFactory.create("media", url)

        haml :display_browse_items, :locals => {:page => page, :title => "We Recommend"}
      else
        page = PageFactory.create("media", url)

        haml :display_browse_items, :locals => {:page => page, :title => "Archive List for all Channels"}
    end
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
      nil
    end
  end

  helpers do
    include Partial

    def display_link_or_folder item
      result = "<a href='#{item.link}'>#{item.text}</a>"

      if item.folder?
        "{#{result}}..."
      else
        result
      end
    end


    def display_link_or_text item
      if item.link
        "<a href='#{item.link}'>#{item.text}</a>"
      else
        item.text
      end
    end
  end
end



