require 'net/https'
require 'nokogiri'
require 'uri'
require 'json'

module Schmap

  class SchmapApi

    attr_accessor :base_url, :username, :password

    cattr_accessor :codes

    def initialize(options = {})
      self.base_url = "https://www.schmap.it/api"
      self.username = options[:username]||ENV["SCHMAP_USERNAME"]
      self.password = options[:password]||ENV["SCHMAP_PASSWORD"]
      self.load_codes
    end

    #@!method followers_of_screen_name
    # These examples will return individual profiles of the 5,000 followers of the screen_name account.
    def individual_followers_of_screen_name(options = {})
      return self.get_individual_profiles(self.format_options("followers_of_screen_name", options)) 
    end

    #@!method followers_of_twitter_id
    # These examples will return individual profiles of the 5,000 followers of the twitter_id account.
    def individual_followers_of_twitter_id(options = {})
      return self.get_individual_profiles(self.format_options("followers_of_twitter_id", options)) 
    end

    #@!method list_of_screen_names
    # These examples will return individual profiles of the max 5,000 listed test accounts, whether specified by 
    # their screennames
    def individual_list_of_screen_names(options = {})
      return self.get_individual_profiles(self.format_options("list_of_screen_names", options))
    end

    #@!method list_of_screen_names
    # These examples will return individual profiles of the max 5,000 listed test accounts, whether specified by 
    # their twitter_ids
    def individual_list_of_twitter_ids(options = {})
      return self.get_individual_profiles(self.format_options("list_of_twitter_ids", options)) 
    end

    #@!method get_individual_profiles
    # This API request returns individual profiles for a defined group of Twitter users, 
    # either the followers of a Twitter account, or specified as a list (for instance, a list 
    # of all users tweeting a certain brand name or keyword). 
    # followers_of_screen_name, followers_of_twitter_id, list_of_screen_names, list_of_twitter_ids
    # if you pass an option called "usage_id", will be used to be charged foreach query done
    # If usage_id == TEST you will receive tests data but no charge for the request.
    
    def get_individual_profiles(options = {})
      #options[:usage_id]||="TEST"
      if options[:data].is_a?(Array) && !options[:data].empty?
        options[:data] << "000000" if options[:data].size == 1
        options[:data] = options[:data].join("|")
      end

      options.merge!({:for => "next_page_of_request_id", :request_id => options[:request_id]}) if options[:request_id].present?
      response = self.call(:post, "get_individual_profiles", options) 
      completed = response["status"] == "pages_pending" ? false : true
      request_id = response["request_id"]

      users ||= []
      response["profiles"]["profiles_data"].collect do |user|
        users << { :twitter_id => user["twitter_id"].to_s, :info => Schmap::Code.decode(user["codes"]) } if !user["twitter_id"].nil?
        users << { :screen_name => user["screen_name"].to_s, :info => Schmap::Code.decode(user["codes"]) } if !user["screen_name"].nil?
      end
      results = {:request_id => request_id, :completed => completed, :users => users}
      return results
    end

    #@!method aggregate_followers_of_screen_name
    # These examples will return aggregate analysis of the 5,000 followers of the screen_name account.
    def aggregate_followers_of_screen_name(options = {})
      return self.get_aggregate_analysis(self.format_options("followers_of_screen_name", options)) 
    end

    #@!method aggregate_followers_of_twitter_id
    # These examples will return aggregate analysis profiles of the 5,000 followers of the twitter_id account.
    def aggregate_followers_of_twitter_id(options = {})
      return self.get_aggregate_analysis(self.format_options("followers_of_twitter_id", options)) 
    end

    #@!method aggregate_list_of_screen_names
    # These examples will return aggregate analysis of the max 5,000 listed test accounts, whether specified by 
    # their screennames
    def aggregate_list_of_screen_names(options = {})
      return self.get_aggregate_analysis(self.format_options("list_of_screen_names", options))
    end

    #@!method aggregate_list_of_twitter_ids
    # These examples will return aggregate analysis of the max 5,000 listed test accounts, whether specified by 
    # their twitter_ids
    def aggregate_list_of_twitter_ids(options = {})
      return self.get_aggregate_analysis(self.format_options("list_of_twitter_ids", options)) 
    end

    #@!method get_aggregate_analysis
    # This API request returns aggregate analysis for a defined group of Twitter users, 
    # either the followers of a Twitter account, or specified as a list (for instance, a list 
    # of all users tweeting a certain brand name or keyword). 
    # followers_of_screen_name, followers_of_twitter_id, list_of_screen_names, list_of_twitter_ids
    # if you pass an option called "usage_id", will be used to be charged foreach query done
    # If usage_id == TEST you will receive tests data but no charge for the request.
    
    def get_aggregate_analysis(options = {})
      #options[:usage_id]||="TEST"
      if options[:data].is_a?(Array) && !options[:data].empty?
        options[:data] << "000000" if options[:data].size == 1
        options[:data] = options[:data].join("|")
      end
      options.merge!({:for => "next_page_of_request_id", :request_id => options[:request_id]}) if options[:request_id].present?
      response = self.call(:post, "get_aggregate_analysis", options) 
      completed = response["status"] == "pages_pending" ? false : true
      request_id = response["request_id"]

      analysis_data ||= []
      response["analysis"]["analysis_data"].collect do |analysis|
        analysis_data << {:analysis_id => response["analysis"]["analysis_id"], :section_total => analysis["section_total"], :section_name => analysis["section_name"], :items => analysis["section_rows"].map{|row| {:name => Schmap::Code.code_to_value(row["code"]), :counter => row["num"]}} }
      end
      results = {:request_id => request_id, :completed => completed, :analysis_data => analysis_data}
      return results
    end

    #!@ method load_codes() load codes in memory
    def load_codes
      @@codes ||= JSON.parse(File.read(File.dirname(__FILE__) + "/../../data/optimized.json"))
    end

    #!@ method format_options() is used to format options to understand if i want next pages
    def format_options(type, options = {})
      if options[:paginated].present? && options[:paginated] && options[:request_id].present? 
        params = { :for => type, :request_id => options[:request_id] }
      else
        params = { :for => type, :data => options[:values] }
      end
      return params
    end

    #@!method call is the method to manage api call get and post, encapsulating the basic_auth
    def call(type, api_call, params = {})
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
      begin
        parsed_response = JSON.parse(response.body)
        if parsed_response["status"] == "Error"
          raise Error, parsed_response["error_details"]
        else
          return parsed_response
        end
      rescue Exception => e
        if e.is_a?(Error)
          raise e
        else
          error = Nokogiri::HTML(response.body)
          raise Error, error.title
        end
      end
    end
  end

  # UTILITIES
  #!@ method update_codes() is used to update the response codes from schmap
  def update_codes
    response = self.call(:get, "get_codes")
    File.open(File.dirname(__FILE__) + "/../../data/codes.json", "w+") do |f|
      f.write(JSON.pretty_generate(response))
    end
    Code.prepare_codes
    @@codes = nil
    load_codes
  end
end