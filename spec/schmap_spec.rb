require 'spec_helper'

describe Schmap::SchmapApi do

  it "Check codes unique keys" do
    keys = Schmap::Code.get_unique_keys
    ["large_accounts_followed", "location_by_city", "first_language", "main_street_shop_at", "location_by_us_state", "main_street_eat_drink_at", "likes_and_interests", "categories_of_account_followed", "location_by_country", "miscellaneous_demographics", "age", "services_and_technologies", "gender", "professions", "number_of_accounts_followed", "main_street_dressed_by", "religion", "twitter_settings", "work_status", "twitter_activity", "race_ethnicity", "twitter_influence", "family_status", "account_type", "time_on_twitter"].collect do |key|
      keys.include?(key).should == true
    end
  end 
  
  it "Passing twitter return followers aggregate analysis" do
    screen_name = "testacc5k"
    client = Schmap::SchmapApi.new
    results = client.aggregate_followers_of_screen_name(:values => screen_name)[:analysis_data].first
    results[:section_total].should == 5000
  end
  
  it "Passing twitter id should return followers aggregate analysis" do
    twitter_id = "123005"
    client = Schmap::SchmapApi.new
    results = client.aggregate_followers_of_twitter_id(:values => twitter_id)[:analysis_data].first
    results[:section_total].should == 5000
    results[:section_name].should == "Countries"
  end
  
  it "Passing twitter ids should return users report" do
    ids = ["12300001", "12300002"]
    client = Schmap::SchmapApi.new
    results = client.aggregate_list_of_twitter_ids(:values => ids)[:analysis_data].first
  end
  
  it "Passing twitter user_names should return users report" do
    screen_names = ["test00001", "test00002"]
    client = Schmap::SchmapApi.new
    results = client.aggregate_list_of_screen_names(:values => screen_names)[:analysis_data].first
  end
  
  
  it "Passing twitter user_name should return all his followers and the last twitter_id should be 12339980" do
    screen_name = "testacc5k"
    client = Schmap::SchmapApi.new
    users = client.individual_followers_of_screen_name(:values => screen_name)[:users]
    users.size.should == 5000
    users.last[:twitter_id].should == "12339980"
  end
  
  it "Passing twitter id should return all his followers and the last twitter_id should be 12339980" do
    twitter_id = "123005"
    client = Schmap::SchmapApi.new
    users = client.individual_followers_of_twitter_id(:values => twitter_id)[:users]
    users.size.should == 5000
    users.last[:twitter_id].should == "12339980"
  end
  
  it "Passing twitter ids should return users info" do
    ids = ["12300001", "12300002"]
    client = Schmap::SchmapApi.new
    users = client.individual_list_of_twitter_ids(:values => ids)[:users]
    users.each_with_index do |user, i|
      user[:twitter_id].should == ids[i]
    end
  end
  
  it "Passing twitter user_names should return users info" do
    screen_names = ["test00001", "test00002"]
    client = Schmap::SchmapApi.new
    users = client.individual_list_of_screen_names(:values => screen_names)[:users]
    users.each_with_index do |user, i|
      user[:screen_name].should == screen_names[i]
    end
  end
  
  it "401 Authorization Required if username and password are wrong" do
    expect do
      screen_names = ["test00001", "test00002"]
      client = Schmap::SchmapApi.new(:username => "test", :password => "123456")
      users = client.individual_list_of_screen_names(:values => screen_names)
    end.to raise_error(Error, "401 Authorization Required")
  end

end