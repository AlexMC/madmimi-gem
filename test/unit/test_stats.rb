require 'helper'
require 'unit/helper'

class TestStats < Test::Unit::TestCase  
  context "A Stats API call" do
    setup do
      @mimi = MadMimi.new('email@example.com', 'testapikey')
    end
    
    should "return mailing stats" do
      stub_get("/promotions/257174/mailings/1274713.xml", "stats.xml")
      response = @mimi.mailing_stats("257174", "1274713")
      flunk "Coudn't get mailing stats." unless response.kind_of?(Hash) || response.keys != ["mailing"]
    end         
  end
end
