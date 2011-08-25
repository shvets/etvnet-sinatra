require 'rubygems' unless RUBY_VERSION =~ /1.9.*/

require 'sinatra/base'
require 'haml'
require 'sass'

require 'etvnet_seek/etvnet_seek'

module Etvnet
  class App < Sinatra::Base
    COOKIE_FILE_NAME = ENV['HOME'] + "/.etvnet-seek"

    set :haml, {:format => :html5, :attr_wrapper => '"'}
    set :views, File.dirname(__FILE__) + '/../../app/views'
    set :public, File.dirname(__FILE__) + '/../../app/public'
    set :sessions, true

    def initialize app=nil
      super
    end

    def login
      session[:original_path] = request.path_info
      redirect "/login"
    end

    get '/javascripts/*' do
      open("#{File.dirname(__FILE__)}/../public/javascripts/#{params[:splat]}")
    end

    get '/stylesheet.css' do
      headers 'Content-Type' => 'text/css; charset=utf-8'
      sass :stylesheet
    end

    get '/login' do
      haml :login, :layout => :login_layout
    end

    post "/login" do
      accessor = Accessor.new COOKIE_FILE_NAME, lambda { login }
      accessor.login request[:username], request[:pwd]

      redirect session[:original_path]
    end

    get '/' do
      main_page = ItemsPageFactory.create("main")
      catalog_page = ItemsPageFactory.create("main")
      best_hundred_page = ItemsPageFactory.create("best_hundred")
      new_items_page = ItemsPageFactory.create("new_items")
      premiere_page = ItemsPageFactory.create("premiere")

      haml :index,
           :locals => {:title => "Home Page",
                       :page => main_page,
                       :catalog => catalog_page,
                       :best_hundred_page => best_hundred_page,
                       :new_items_page => new_items_page,
                       :premiere_page => premiere_page}
    end

    get '/search/' do
      url = request.fullpath
      page = ItemsPageFactory.create("search", url.gsub("/search/?", ""))

      haml :display_catalog_items, :locals => {:page => page}

#     url = request.fullpath
#
#      page = ItemsPageFactory.create("media", url)
#
#      if page.items.size > 0
#        haml :display_container_items, :locals => {:page => page}
#      else
#        name = page.document.css(".info-movie-title h1").text
#        current_item = BrowseMediaItem.new(name, request.path_info)
#
#        accessor = Accessor.new COOKIE_FILE_NAME, lambda { login }
#
#        result = accessor.access current_item, session, request
#
#        while(accessor.try_again? or result.nil?) do
#          result = accessor.access current_item, session, request
#        end
#
#        if result
#          haml :display_media, :locals => {:page => page, :link_info => result}
#        end
#      end
    end

    get '/tv_channels/' do
      url = request.fullpath

      page = ItemsPageFactory.create("channels", url)

      haml :display_channel_items, :locals => {:page => page}
    end

    get '/tv_channel/today/*/' do
      url = request.fullpath

      page = ItemsPageFactory.create("media", url)

      haml :display_catalog_items, :locals => {:page => page}
    end

    get '/tv_channel/*/' do
      url = request.fullpath

      page = ItemsPageFactory.create("media", url)

      haml :display_catalog_items, :locals => {:page => page}
    end

    get '/aired_today/' do
      url = request.fullpath
      page = ItemsPageFactory.create("media", url)

      haml :display_catalog_items, :locals => {:page => page}
    end

    get '/catalog/' do
      url = request.fullpath
      page = ItemsPageFactory.create("media", url)

      haml :display_catalog_items, :locals => {:page => page}
    end

    get '/audio/' do
      url = request.fullpath
      page = ItemsPageFactory.create("audio", url)

      haml :display_audio_items, :locals => {:page => page}
    end

#    get '/radio/' do
#      url = request.fullpath
#
#      page = ItemsPageFactory.create("radio", url)
#
#      current_item = MediaItem.new(name, request.path_info)
#
#      media_info = MediaInfo.new current_item.link
#      LinkInfo.new(current_item, media_info)
#
#      haml :display_audio_items, :locals => {:page => page}
#    end

    # audio/today_genres/
    # /audio/newest/person/
    # /audio/catalog/person/

    get '/*/*/' do
      url = request.fullpath

      page = ItemsPageFactory.create("media", url)

      if page.items.size > 0
        haml :display_container_items, :locals => {:page => page}
      else
        name = page.document.css(".info-movie-title h1").text
        current_item = BrowseMediaItem.new(name, request.path_info)

        accessor = Accessor.new COOKIE_FILE_NAME, lambda { login }

        result = accessor.access current_item, session, request

        while(accessor.try_again? or result.nil?) do
          result = accessor.access current_item, session, request
        end

        if result
          haml :display_media, :locals => {:page => page, :link_info => result}
        end
      end
    end

    helpers do
      include Partial
      include Rack::Utils

      alias_method :h, :escape_html

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
          result = "<a href='#{item.link}'>#{item.text}</a>"

          item.additional_info ? result + item.additional_info : result
        else
          item.text
        end
      end
    end
  end
end
