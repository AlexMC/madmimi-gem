require 'helper'
require 'remote/helper'

class TestRemoteLists < Test::Unit::TestCase
  context "An List Managment API call" do
    setup do
      @mimi = MadMimi.new(USERNAME, API_KEY)
    end
    
    # should "retrieve a hash of users found with the search term nicholas" do
    #       response = @mimi.audience_search('nicholas')
    #       flunk "No users found." unless response.kind_of?(Hash) || !response.empty?
    #     end
    
    should "create a new list" do
      response = @mimi.new_list("new_list")
      assert response.headers["status"] == "200", "Response was not success"
      assert @mimi.lists["lists"].first.last.collect{|list| list["name"]}.include?("new_list")
    end
    
    should "retrieve a hash of lists" do
      response = @mimi.lists
      assert response.headers["status"] == "200", "Response was not success"
      assert_kind_of Hash, response, "Response isn't a Hash"
      assert response.keys == ['lists'], "Response didn't return hash of lists"
    end
    
    should "delete a list" do
      response = @mimi.delete_list("new_list")
      assert response.headers["status"] == "200", "Response was not success"
    end
    
   should "import audience members via csv" do
      response = @mimi.csv_import("email,first name,last name,add_list\ndave@example.com,Dave,Hoover,customer")
      assert response.headers["status"] == "200", "Response was not success"
    end

    should "retrieve list membership status" do
      @mimi.add_to_list("dave@example.com", "customer", :first_name => "Dave", :last_name => "Hoover")
      response = @mimi.memberships('dave@example.com')
      assert response.headers["status"] == "200", "Response was not success"
      assert response["lists"]["list"]["name"] == "customer"
    end
    
    should "import audience members via hash" do
      response = @mimi.add_user(:email => "dave@example.com", :first_name => "Dave", :last_name => "Hoover", :add_list => "customer")
      assert response.headers["status"] == "200", "Response was not success"
    end
        
    should "add an audience list membership" do
      response = @mimi.add_to_list("dave@example.com", "customer", :first_name => "Dave", :last_name => "Hoover")
      assert response.headers["status"] == "200", "Response was not success"
    end    
    
    should "remove an audience list membership" do
      response = @mimi.remove_from_list('dave@example.com', 'customer' )
      assert response.headers["status"] == "200", "Response was not success"
    end
    
    should "supress ane email address" do
      response = @mimi.suppress_email("dave@example.com")
      assert response.headers["status"] == "200", "Response was not success"
    end
    
    
    should "retrieve a hash of users suppresed since a timestamp" do
      timestamp = Time.now.to_i
      response = @mimi.suppressed_since(timestamp)
      assert response.headers["status"] == "200", "Response was not success"
    end
              
    should "retrieve a hash of promotions" do
      response = @mimi.promotions
      assert response.headers["status"] == "200", "Response was not success"
    end
        
  end
end
