require 'helper'
require 'unit/helper'

class TestMailer < Test::Unit::TestCase  
  context "An Mailer API call" do
    setup do
      @mimi = MadMimi.new('email@example.com', 'testapikey')
      @options = { 
        :promotion_name  => 'Test Promotion', 
        :from => 'MadMimi Ruby <rubygem@madmimi.com>', 
        :subject => 'Test Subject' 
      }
      
      @body =  {
        :greeting => 'Hello', 
        :name => 'Nicholas'
      }
      
      @raw_html ="<html><head><title>My great promotion!</title></head><body>Body stuff[[tracking_beacon]]</body></html>" 
      @plain_text = "Plain text email contents"
    end
    
    context "sending a promotion" do
      should "send to one recipient" do
        stub_post('/mailer')
        response = @mimi.send_mail(@options.merge(:recipients => 'Nicholas Young <nicholas@madmimi.com>'), @body )
        flunk "Coudn't send promotion to recipient." unless response.code == 200
      end

      should "send to a list" do
        stub_post('/mailer/to_list')
        response = @mimi.send_mail(@options.merge(:list_name => 'my_list'), @body )
        flunk "Couldn't send promotion to list" unless response.code == 200
      end
    end
    
    
    context "raw html email" do
      should "send to one recipient" do
        stub_post('/mailer')
        response = @mimi.send_html(@options.merge(:recipients => 'Nicholas Young <nicholas@madmimi.com>'), @raw_html )
        flunk "Coudn't send html email to recipient." unless response.code == 200
      end

      should "send to a list" do
        stub_post('/mailer/to_list')
        response = @mimi.send_html(@options.merge(:list_name => 'my_list'), @raw_html+"[[unsubscribe]]" )
        flunk "Couldn't send promotion to list" unless response.code == 200
      end

      should "require either tracking_beacon or peek_image" do
        assert_raise MadMimi::MadMimiError do
          @mimi.send_html(@options.merge(:list_name => 'my_list'), @raw_html.gsub("[[tracking_beacon]]", ""))
        end
      end

      should "require unsubscribe or opt_out for sending to list" do
        assert_raise MadMimi::MadMimiError do
          @mimi.send_html(@options.merge(:list_name => 'my_list'), @raw_html)
        end
      end
    end
     
    context "plaintext email" do
      should "send to one recipient" do
        stub_post('/mailer')
        response = @mimi.send_plaintext(@options.merge(:recipients => 'Nicholas Young <nicholas@madmimi.com>'), @plain_text )
        flunk "Coudn't send plaintext email to recipient." unless response.code == 200
      end
      
      should "send to a list" do
        stub_post('/mailer/to_list')
        response = @mimi.send_plaintext(@options.merge(:list_name => 'my_list'), @plain_text+"[[unsubscribe]]" )
        flunk "Couldn't send promotion to list" unless response.code == 200
      end
      
      should "require unsubscribe or opt_out for sending to list" do
        assert_raise MadMimi::MadMimiError do
          @mimi.send_plaintext(@options.merge(:list_name => 'my_list'), @plain_text)
        end
      end
    end
    
            
  end
end
