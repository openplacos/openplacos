# -*- coding: utf-8 -*-
#    This file is part of Openplacos.
#
#    Openplacos is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Openplacos is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.

require 'socket'
require 'net/http'
require 'json'
require 'oauth2'
require 'yaml'


require File.dirname(__FILE__) + "/widget/modules.rb"


module OAuth2
  class AccessToken
    def to_hash()
      token_params = @params
      token_params['access_token'] = @token
      token_params.merge!(@options)
      token_params
    end

  end
end


module Openplacos

  module Connection

    def register( )
      # register the client (automatic way)
      postData = Net::HTTP.post_form(URI.parse("#{@url}/oauth/apps"), 
                                     { 'name'        =>"#{@name}",
                                       'redirect_uri'=>@redirect_uri,
                                       'format'      =>'json'
                                     }
                                     )
      if postData.code == "200"            # Check the status code   
        client_param = JSON.parse( postData.body)
      else
        puts "error code"
        exit 0
      end

      @client_id = client_param["client_id"]
      @client_secret = client_param["client_secret"]
    end

    def create_client
      @client = OAuth2::Client.new(@client_id,
                                   @client_secret,
                                   {:site => "#{@url}", 
                                     :token_url => '/oauth/authorize'
                                   }
                                   )      
    end

    def get_grant_url(type_)
	  @client.auth_code.authorize_url(:redirect_uri => @redirect_uri, :scope => @scope.join(" "))
    end

    def save_config
      token_params                 = @token.to_hash
      token_params[:client_id]     = @client_id
      token_params[:client_secret] = @client_secret

      File.open(@file_config, 'w') do |out|
        YAML::dump( token_params, out )
      end
    end

    def load_config
      @token_params  = YAML::load(File.read(@file_config))
      @client_id     = @token_params.delete(:client_id)    
      @client_secret = @token_params.delete(:client_secret)
    end
       
    def recreate_token
      @token = OAuth2::AccessToken.from_hash(@client, @token_params)
    end

  end


  class Connection_auth_code
    include Connection

    def initialize(url_, name_, scope_, id_, port_)
      @url = url_
      @name = name_
      @scope = scope_
      @redirect_uri = "http://0.0.0.0:#{port_}"
      @port = port_

      dir_config = "#{ENV['HOME']}/.openplacos"
      if !Dir.exists?(dir_config)
        Dir.mkdir(dir_config)
      end

      @file_config = "#{dir_config}/#{@name}-#{id_}.yaml"

      if !File.exists?(@file_config) #get token -- first time
        register 
        create_client
        grant
        get_token
        save_config
      else        # persistant mode
        load_config
        create_client
        recreate_token
      end
      puts @token.get('/me').body
    end

private
    def grant ()
      go_to_url  = get_grant_url("code")

      puts "***************"
      puts "please open your webBrowser and got to :"
      puts go_to_url
      puts "***************"

      @auth_code = get_auth_code
    end

    def get_auth_code()
      # listen to get the auth code
      server = TCPServer.new(@port)
      re=/code=(.*)&scope/
      authcode = nil
      while (session = server.accept)
        request = session.gets
        authcode = re.match(request)
        if !authcode.nil?
          session.print "HTTP/1.1 200/OK\rContent-type: text/html\r\n\r\n"
          session.puts "<h1>Auth successfull</h1>"
          session.close
          break 
        end
      end
      authcode[1]
    end

    def get_token()
      begin
        @token = @client.auth_code.get_token(@auth_code, {:redirect_uri => @redirect_uri},{:mode=>:header, :header_format=>"OAuth %s", :param_name=>"oauth_token"})
      rescue => e
        puts e.description
        Process.exit 42
      end
    end
    
  end


  class Client

    attr_accessor :config, :objects, :service, :sensors, :actuators, :rooms,  :reguls, :initial_room
    
    def initialize(url_, name_, scope_, connection_type, id_ = "0", opt_={})
      case connection_type
      when "auth_code" then
        @connection =  Connection_auth_code.new(url_, name_, scope_, id_, opt_[:port] || 2000)
      end
      
      

    end
       


    
  end










end
