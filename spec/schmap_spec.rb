require 'spec_helper'

describe Schmap::SchmapApi do

  it "Passing twitter user_name should return all his followers and the last twitter_id should be 12339980" do
    screen_name = "testacc5k"
    client = Schmap::SchmapApi.new
    users = client.followers_of_screen_name(screen_name)
    users.size.should == 5000
    users.last[:twitter_id].should == "12339980"
  end
  
  it "Passing twitter id should return all his followers and the last twitter_id should be 12339980" do
    twitter_id = "123005"
    client = Schmap::SchmapApi.new
    users = client.followers_of_twitter_id(twitter_id)
    users.size.should == 5000
    users.last[:twitter_id].should == "12339980"
  end
  
  it "Passing twitter ids should return users info" do
    ids = ["12300001", "12300002"]
    client = Schmap::SchmapApi.new
    users = client.list_of_twitter_ids(ids)
    users.each_with_index do |user, i|
      user[:twitter_id].should == ids[i]
    end
  end
  
  it "Passing twitter user_names should return users info" do
    screen_names = ["test00001", "test00002"]
    client = Schmap::SchmapApi.new
    users = client.list_of_screen_names(screen_names)
    users.each_with_index do |user, i|
      user[:screen_name].should == screen_names[i]
    end
  end

  it "401 Authorization Required if username and password are wrong" do
    expect do
      screen_names = ["test00001", "test00002"]
      client = Schmap::SchmapApi.new(:username => "test", :password => "123456")
      users = client.list_of_screen_names(screen_names)
    end.to raise_error(Error, "401 Authorization Required")
  end

end