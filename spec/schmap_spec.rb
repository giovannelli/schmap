require 'spec_helper'

describe Schmap::SchmapApi do
  #TODO: In porgress
  
  it "Passing twitter return followers aggregate analysis" do
    screen_name = "testacc5k"
    client = Schmap::SchmapApi.new(:username => "face_apitest", :password => "886hj27ltar0")
    results = client.aggregate_followers_of_screen_name(screen_name).first
    results[:section_total].should == 5000
  end
  
  # it "Passing twitter id should return followers aggregate analysis" do
  #   twitter_id = "123005"
  #   client = Schmap::SchmapApi.new
  #   results = client.aggregate_followers_of_twitter_id(twitter_id)
  #   results[:section_total].should == 5000
  #   results[:section_name].should == "Followed Accounts"
  #   results[:analysis_id].should == "533649"
  # end
  # 
  # it "Passing twitter ids should return users report" do
  #   ids = ["12300001", "12300002"]
  #   client = Schmap::SchmapApi.new
  #   results = client.aggregate_list_of_twitter_ids(ids)
  #   results[:analysis_id].should == "533649"
  # end
  # 
  # it "Passing twitter user_names should return users report" do
  #   screen_names = ["test00001", "test00002"]
  #   client = Schmap::SchmapApi.new
  #   results = client.aggregate_list_of_screen_names(screen_names)
  #   results[:analysis_id].should == "533649"
  # end
  

  it "Passing twitter user_name should return all his followers and the last twitter_id should be 12339980" do
    screen_name = "testacc5k"
    client = Schmap::SchmapApi.new
    users = client.individual_followers_of_screen_name(screen_name)
    users.size.should == 5000
    users.last[:twitter_id].should == "12339980"
  end

  it "Passing twitter id should return all his followers and the last twitter_id should be 12339980" do
    twitter_id = "123005"
    client = Schmap::SchmapApi.new
    users = client.individual_followers_of_twitter_id(twitter_id)
    users.size.should == 5000
    users.last[:twitter_id].should == "12339980"
  end

  it "Passing twitter ids should return users info" do
    ids = ["12300001", "12300002"]
    client = Schmap::SchmapApi.new
    users = client.individual_list_of_twitter_ids(ids)
    users.each_with_index do |user, i|
      user[:twitter_id].should == ids[i]
    end
  end

  it "Passing twitter user_names should return users info" do
    screen_names = ["test00001", "test00002"]
    client = Schmap::SchmapApi.new
    users = client.individual_list_of_screen_names(screen_names)
    users.each_with_index do |user, i|
      user[:screen_name].should == screen_names[i]
    end
  end

  it "401 Authorization Required if username and password are wrong" do
    expect do
      screen_names = ["test00001", "test00002"]
      client = Schmap::SchmapApi.new(:username => "test", :password => "123456")
      users = client.individual_list_of_screen_names(screen_names)
    end.to raise_error(Error, "401 Authorization Required")
  end

end