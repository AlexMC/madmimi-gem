require 'helper'
require 'unit/helper'

class TestLists < Test::Unit::TestCase
  context "An List Managment API call" do
    setup do
      @mimi = MadMimi.new('email@example.com', 'testapikey')
    end
    
    should "retrieve a hash of users found with the search term nicholas" do
      stub_get('/audience_members/search.xml?query=nicholas', 'search.xml')
      response = @mimi.audience_search('nicholas')
      flunk "No users found." unless response.kind_of?(Hash) || !response.empty?
    end
    
    should "create a new list" do
      stub_post('/audience_lists')
      response = @mimi.new_list("new_list")
      flunk "List creation failed." unless response.code == 200
    end
    
    should "delete a list" do
      stub_delete("/audience_lists/new_list")
      response = @mimi.delete_list("new_list")
      flunk "List deletion failed." unless response.code == 200
    end
    
    should "retrieve a hash of lists" do
      stub_get('/audience_lists/lists.xml', 'lists.xml')
      response = @mimi.lists
      flunk "Doesn't return any lists." unless response.kind_of?(Hash) || response.keys != ["lists"]
    end

    should "retrieve list membership status" do
      stub_get('/audience_members/email@example.com/lists.xml', 'membership.xml')
      response = @mimi.memberships('email@example.com')
      flunk "I couldn't find any memberships." unless response.kind_of?(Hash) || response.keys != ["lists"]
    end
     
    should "import audience members via csv" do
      stub_post('/audience_members')
      response = @mimi.csv_import("email,first name,last name,add_list\ndave@example.com,Dave,Hoover,customer\ncolin@example.com,Colin,Harris,investor")
      flunk "CSV import failed." unless response.code == 200
    end
    
    should "import audience members via hash" do
      stub_post('/audience_members')
      response = @mimi.add_user(:email => "dave@example.com", :first_name => "Dave", :last_name => "Hoover", :add_list => "customer")
      flunk "Hash import failed." unless response.code == 200
    end
    
    should "add an audience list membership" do
      stub_post('/audience_lists/customer/add')
      response = @mimi.add_to_list("dave@example.com", "customer", :first_name => "Dave", :last_name => "Hoover")
      flunk "Adding user to list failed." unless response.code == 200
    end
    
    should "remove an audience list membership" do
      stub_post('/audience_lists/customer/remove')
      response = @mimi.remove_from_list('email@example.com', 'customer' )
      flunk "Removing user from list failed." unless response.code == 200
    end
    
    should "supress ane email address" do
      stub_post("/audience_members/dave@example.com/suppress_email")
      response = @mimi.suppress_email("dave@example.com")
      flunk "Couldn't suppress an email." unless response.code == 200
    end
    
    should "retrieve a hash of users suppresed since a timestamp" do
      timestamp = Time.now.to_i
      stub_get("/audience_members/suppressed_since/#{timestamp.to_s}.txt", "suppressed.txt")
      response = @mimi.suppressed_since(timestamp)
      flunk "I couldn't find any supressed users." unless response.kind_of?(String) && !response.empty?
    end
      
    should "retrieve a hash of promotions" do
      stub_get('/promotions.xml', 'promotions.xml')
      response = @mimi.promotions
      flunk "I couldn't find any promotions." unless response.kind_of?(Hash) || response.keys != ["promotions"]
    end
        
  end
end
