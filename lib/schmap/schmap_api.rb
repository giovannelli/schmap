require 'net/https'
require 'uri'
require 'json'

module Schmap

  class SchmapApi
    
    attr_accessor :base_url, :username, :password
    
    def initialize(options = {})
      self.base_url = "https://www.schmap.it/api"
      self.username = options[:username] || ENV["SCHMAP_USERNAME"]
      self.password = options[:password] || ENV["SCHMAP_PASSWORD"]
      self.update_codes
    end

    #@!method followers_of_screen_name
    # These examples will return individual profiles of the 5,000 followers of the screen_name account.
    def followers_of_screen_name(screen_name)
      params = { :for => "followers_of_screen_name", :data => screen_name.to_s }
      return self.get_individual_profiles(params) 
    end

    #@!method followers_of_twitter_id
    # These examples will return individual profiles of the 5,000 followers of the twitter_id account.
    def followers_of_twitter_id(twitter_id)
      params = { :for =>  "followers_of_twitter_id", :data =>  twitter_id }
      return self.get_individual_profiles(params) 
    end

    #@!method list_of_screen_names
    # These examples will return individual profiles of the max 5,000 listed test accounts, whether specified by 
    # their screennames
    def list_of_screen_names(screen_names_array = [])
      params = { :for =>  "list_of_screen_names", :data =>  screen_names_array }
      return self.get_individual_profiles(params) 
    end

    #@!method list_of_screen_names
    # These examples will return individual profiles of the max 5,000 listed test accounts, whether specified by 
    # their twitter_ids
    def list_of_twitter_ids(twitter_ids_array = [])
      params = { :for =>  "list_of_twitter_ids", :data =>  twitter_ids_array}
      return self.get_individual_profiles(params) 
    end

    #@!method get_individual_profiles
    # This API request returns individual profiles for a defined group of Twitter users, 
    # either the followers of a Twitter account, or specified as a list (for instance, a list 
    # of all users tweeting a certain brand name or keyword). 
    # followers_of_screen_name, followers_of_twitter_id, list_of_screen_names, list_of_twitter_ids

    def get_individual_profiles(options = {})
      begin
        pages ||= []
        if options[:data].is_a?(Array) && !options[:data].empty?
          options[:data] << "000000" if options[:data].size == 1
          options[:data] = options[:data].join("|")
        end
        response = self.call(:post, "get_individual_profiles", options) 
        if response["status"] == "pages_pending"
          pages << get_individual_profiles(:for =>  "next_page_of_request_id")
        else
          pages << JSON.parse(response)
        end
        users ||= []
        pages.collect do |page|
          page["profiles"]["profiles_data"].collect do |user|
            users << { :twitter_id => user["twitter_id"].to_s, :codes => user["codes"] } if !user["twitter_id"].nil?
            users << { :screen_name => user["screen_name"].to_s, :codes => user["codes"] } if !user["screen_name"].nil?
          end
        end
        return users
      rescue Exception => e
        puts e
      end
    end

    def update_codes
      @@codes_map ||= JSON.parse(self.call(:get, "get_codes"))["sections_list"]
    end

    #@!method call is the method to manage api call get and post, encapsulating the basic_auth
    def call(type, api_call, params = {})
      begin
        uri = URI.parse("#{self.base_url}/#{api_call}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        case type
        when :post
          request = Net::HTTP::Post.new(uri.request_uri)
        when :get
          request = Net::HTTP::Get.new(uri.request_uri)
        end
        request.set_form_data(params) if !params.empty?
        request.basic_auth  self.username, self.password
        response = http.request(request)
        case response
        when Net::HTTPSuccess then
          return response.body
        else
          return response.body
        end
      rescue Exception => e
        puts e
      end
    end
  end
end