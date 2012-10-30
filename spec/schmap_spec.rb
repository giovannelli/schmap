require 'spec_helper'

describe Schmap::SchmapApi do
  it "It should return user 12300001 and 12300002 info" do
    ids = ["12300001", "12300002"]
    client = Schmap::SchmapApi.new
    users = client.list_of_twitter_ids(ids)
    users.each_with_index do |user, i|
      user[:twitter_id].should == ids[i]
    end
  end
end