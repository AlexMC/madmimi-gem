require 'helper'

class TestGetters < Test::Unit::TestCase
  context "getter methods" do
    setup do
      @mimi = MadMimi.new('email@example.com', 'testapikey')
    end

    should "retrieve username" do
      flunk "Didn't return username" unless @mimi.username == "email@example.com"
    end
    
    should "retrieve api key" do
      flunk "Didn't return api key" unless @mimi.api_key == "testapikey"
    end
    
  end
end