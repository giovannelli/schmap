# Schmap api [![Build Status](https://travis-ci.org/giovannelli/schmap.png)](https://travis-ci.org/giovannelli/schmap)

Schmap brings you up close and personal with the **demographics**.
To test locally you need a test account on schmaps used to freely evaluate the API using a number of sandboxed test Twitter accounts 
and individual test users.

Schmap Consumer Profiling API returns aggregate analysis and individual profiles for a defined group of Twitter users, either the followers of a Twitter account, or specified 
as a list (for instance, a list of all users tweeting a certain brand name or keyword).


# Configuration
You can pass username and password to the SchmapApi constructor or you can define two ENV variables:

```ruby
ENV["SCHMAP_USERNAME"] 
ENV["SCHMAP_PASSWORD"]
```

# Usage Examples

Getting information of two twitter user by theirs screen names:

```ruby
require 'schmap'

client = SchmapApi.new(:username => "test", :password => "test")

users = client.list_of_screen_names(["giovannelli", "alessani"]) 
```