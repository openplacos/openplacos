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

  module String

    # this method extend string module. 
    # this module find out a module instance from it's name (=string)
    # ( "Openplacos::Analog" (=string) => Oenplacos::Analog (= module)  
    def get_max_const
      array = self.split("::")
      out = Kernel
      array.each { |mod|
        if out.const_defined?(mod)
          out = out.const_get(mod)
        else
          return out
        end
      }
      return out #Should never be here
    end
  end
  
  module Connection

    # register the client (automatic way)
    def register( )
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

    # save config with token, client_id and secret into a userspace directory
    # needed to not regrant client every connection
    def save_config
      @token_params[@url]                 = @token ? @token.to_hash : {}
      @token_params[@url][:client_id]     = @client_id
      @token_params[@url][:client_secret] = @client_secret

      File.open(@file_config, 'w') do |out|
        YAML::dump( @token_params, out )
      end
    end

    # restore config 
    def load_config
      if File.exists?(@file_config)
        @token_params  = YAML::load(File.read(@file_config))
        if @token_params[@url]
          @client_id     = @token_params[@url][:client_id] 
          @client_secret = @token_params[@url][:client_secret]
        end
      else
        @token_params = Hash.new
      end
    end
       
    def recreate_token
      @token = OAuth2::AccessToken.from_hash(@client, @token_params[@url])
    end

  end

  class Connection_password
    include Connection
    attr_reader :token
    def initialize(url_, name_, scope_, id_, port_, username_, password_)
      @url          = url_
      @name         = name_
      @scope        = scope_
      @id           = id_
      @redirect_uri = "http://0.0.0.0:#{port_}"
      @port         = port_
      @username     = username_
      @password     = password_
      
      
      dir_config = "#{ENV['HOME']}/.openplacos"
      if !Dir.exists?(dir_config)
        Dir.mkdir(dir_config)
      end

      @file_config = "#{dir_config}/#{@name}-#{id_}.yaml"
      
      load_config
      if @token_params[@url].nil? #create -- first time
        register 
        create_client
        save_config
      else        # persistant mode
        create_client
      end
      get_token 

    end
    
    private 
    
    def get_token
        @token = @client.password.get_token(@username, @password, {:redirect_uri => @redirect_uri},{:mode=>:header, :header_format=>"OAuth %s", :param_name=>"oauth_token"})
    end
    
  end

  class Connection_auth_code
    include Connection
    attr_reader :token

    # Open a connection to openplacos server
    # Please give:
    # * opos url
    # * an application name that identify the client oath2 talking
    # * a scope, typically ["read", "write", "user"] 
    # * an optionnal id, to manage several clients
    # * port of openplacos server
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

      # config saved to avoir re-grant at each connection
      @file_config = "#{dir_config}/#{@name}-#{id_}.yaml"
      
      load_config
      if @token_params[@url].nil? #get token -- first time
        register 
        create_client
        grant
        get_token
        save_config
      else        # persistant mode
        create_client
        recreate_token
      end
    end

private
    # display a message indicating url for grant
    # this method can be overloaded by client depending it's interface with user
    def grant ()
      go_to_url  = get_grant_url("code")

      puts "***************"
      puts "Please open your web browser and got to :"
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


  class Connection_from_token
    attr_accessor :token
    def initialize(tok_)
      @token = tok_
    end
  end
  
  class Client

    attr_accessor :config, :objects, :service, :sensors, :actuators, :rooms,  :reguls, :initial_room
    
    # Initialize a connection to server with OAuth2 in a automatic way
    # Please provide url server, application name, permission needed for application
    # Set connection_type to auth_code to use with oauth2 flow
    # You can access to proxyfied objects with .objects attribute
    # Please give:
    # * opos url
    # * an application name that identify the client oath2 talking
    # * a scope, typically ["read", "write", "user"] 
    # * a connection_type, set it to "auth_code" to use oauth2 with classic flow (recommanded)
    # or with "password" to use with password flow. Set to "inception" to pass a connection
    # object through opt{:connection} 
    # * an optionnal id, to manage several clients
    # * an optionnal option hash, in which you can specify openplacos port { :port => 5454 }
    # * You can also pass a token object through opt[:token] that is an oauth2 object. 
    def initialize(url_, name_, scope_, connection_type_, id_ = "0", opt_={})

      @objects = Hash.new
      @connection_type = connection_type_
      if opt_[:token].nil?
        case @connection_type
        when "auth_code" then
          @connection =  Connection_auth_code.new(url_, name_, scope_, id_, opt_[:port] || 2000)
        when "password" then
          @connection = Connection_password.new(url_, name_, scope_, id_, opt_[:port] || 2000, opt_[:username], opt_[:password])
        else
          raise "unknow grant type"
        end
      else
        @connection = Connection_from_token.new(opt_[:token])
      end
      introspect
      extend_objects
    end

    # Intropect the distant server
    def introspect
      @introspect = JSON.parse( @connection.token.get('/ressources').body)
      @introspect.each { |obj|
        @objects[obj["name"]] = ProxyObject.new(@connection, obj) 
      }
    end
    
    def get_iface_type(obj, det_)
      a = Array.new
      obj.interfaces.each { |iface|
        if(iface.include?(det_))
          a << iface
        end
      }
      a
    end
    
    def extend_objects
      @objects.each_pair{ |key, obj|
        if (key != "/informations")
          obj.interfaces.each { |iface|
            extend_iface(iface, obj[iface])
          }
        end
      }
    end
    
    # Extend an object to a ruby module according to iface_name_
    # if iface_name_ is "org.openplacos.analog.order"
    # => object will inherit Openplacos::Analog::Order
    def extend_iface(iface_name_,obj_ )
      mod = "Openplacos::"+ construct_module_name(iface_name_)
      mod.extend(Openplacos::String)
      obj_.extend(mod.get_max_const)
    end

    # transform iface_name to a module name that obj will inherit
    def construct_module_name(iface_name_)
      iface_heritage = iface_name_.sub(/org.openplacos./, '').split('.')
      iface_heritage.each { |s|
        s.capitalize!
      }
      iface_heritage.join('::')
    end
    
    # return the user name
    def me
      JSON.parse(@connection.token.get("/me").body)["username"]
    end
   
  end


  class ProxyObject
  
    attr_reader :path
    
    # Object abstraction of a ressources
    # Contructed from instrospect
    # Has interfaces
    def initialize(connection_, introspect_)
      @path = introspect_["name"]
      @interfaces = Hash.new
      introspect_["interfaces"].each_pair { |name, methods|
        @interfaces[name]= ProxyObjectInterface.new(connection_, self, name, methods)
      }
    end
    
     # Returns the interfaces of the object.
    def interfaces
      @interfaces.keys
    end

    # Retrieves an interface of the proxy object (ProxyObjectInterface instance).
    def [](intfname)
      @interfaces[intfname]
    end

    # Maps the given interface name _intfname_ to the given interface _intf.
    def []=(intfname, intf)
      @interfaces[intfname] = intf
    end 

    def has_iface?(iface_)
      return interfaces.include?(iface_)
    end
   
  end

  class ProxyObjectInterface

    # Interface abstraction
    # contruct from introspect
    def initialize(connection_, proxyobj_, name_, methods_)
      @connection = connection_
      @proxyobject = proxyobj_
      @name    = name_
      @methods = Hash.new
      methods_.each {  |meth|
        @methods[meth] = define_method(meth)
      }
    end

    # Define a proxyfied method from its name
    def define_method(name_)
     if name_=="read"
     methdef =  <<-eos
                   def read(option_ = {})
                     res = JSON.parse(@connection.token.get('/ressources/#{@proxyobject.path}', :params => {'iface'=> '#{@name}', 'options' => (option_).to_json}).body)
                     res["value"]
                   end
eos
    end
    if name_=="write"
     methdef =  <<-eos
                   def write(value_,option_ = {})
                     res = JSON.parse(@connection.token.post('/ressources/#{@proxyobject.path}', :params => {'iface'=> '#{@name}', 'value' => [value_].to_json, 'options' => (option_).to_json}).body)
                     res["status"]
                   end
eos
    end
    
        instance_eval( methdef )
      end
  end

end
