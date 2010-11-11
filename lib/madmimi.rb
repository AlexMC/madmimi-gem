#   Mad Mimi for Ruby

#   License

#   Copyright (c) 2010 Mad Mimi (nicholas@madmimi.com)

#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:

#   The above copyright notice and this permission notice shall be included in
#   all copies or substantial portions of the Software.

#   Except as contained in this notice, the name(s) of the above copyright holder(s) 
#   shall not be used in advertising or otherwise to promote the sale, use or other
#   dealings in this Software without prior written authorization.

#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#   THE SOFTWARE.

require 'rubygems'
require 'httparty'
require 'csv'

class MadMimi
  
  include HTTParty
  base_uri 'api.madmimi.com'
  format :xml
  
  UNSUBSCRIBE_ERROR_MESSAGE = "When specifying list_name, include the [[unsubscribe]] or [[opt_out]] macro in your HTML before sending."
  UNSUBSCRIBE_TEXT_ERROR_MESSAGE = "You'll need to include either the [[unsubscribe]] or [[opt_out]] macro in your text before sending."
  TRACKING_ERROR_MESSAGE =    "You'll need to include either the [[tracking_beacon]] or [[peek_image]] macro in your HTML before sending."

  class MadMimiError < StandardError; end

  def initialize(username, api_key)
    @api_settings = { :username => username, :api_key => api_key }
    self.class.default_params @api_settings
  end

  def username
    @api_settings[:username]
  end

  def api_key
    @api_settings[:api_key]
  end

  #
  # Mailer Methods
  #
  
  def send_mail(opt, yaml_body)
    options = opt.dup
    options[:body] = yaml_body.to_yaml
    if !options[:list_name].nil?
      self.class.post('/mailer/to_list', options)
    else
      self.class.post('/mailer', options)
    end
  end
  
  def send_html(opt, html)
    options = opt.dup
    unless html.include?('[[tracking_beacon]]') || html.include?('[[peek_image]]')
      raise MadMimiError, TRACKING_ERROR_MESSAGE
    end
        
    options[:raw_html] = html
    unless options[:list_name].nil?
      unless html.include?('[[unsubscribe]]') || html.include?('[[opt_out]]')
        raise MadMimiError, UNSUBSCRIBE_ERROR_MESSAGE
      end
      self.class.post('/mailer/to_list', options)
    else
      self.class.post('/mailer', options)
    end

  end

  def send_plaintext(opt, plaintext)
    options = opt.dup
    options[:raw_plain_text] = plaintext
    unless options[:list_name].nil?
      unless plaintext.include?('[[unsubscribe]]') || plaintext.include?('[[opt_out]]')
        raise MadMimiError, UNSUBSCRIBE_TEXT_ERROR_MESSAGE
      end
      self.class.post('/mailer/to_list', options)
    else
      self.class.post('/mailer', options)
    end
  end
  
  #
  # List Managment Methods
  #
  
  def audience_search(query_string, raw = false)
    options = raw ? {:raw => raw} : {}
    self.class.get("/audience_members/search.xml?query=#{query_string}", options)
  end
  
  def new_list(list_name)
    self.class.post('/audience_lists', :body => {:name => list_name})
  end

  def delete_list(list_name)
    self.class.delete("/audience_lists/#{URI.escape(list_name)}")
  end
  
  def lists
    self.class.get('/audience_lists/lists.xml')
  end

  def memberships(email)
    self.class.get("/audience_members/#{email}/lists.xml")
  end

  def csv_import(csv_string)
    self.class.post('/audience_members', :body => {:csv_file => csv_string})
  end

  def add_user(options)
    csv_import(build_csv(options))
  end
  
  def add_to_list(email, list_name, options={}) 
    self.class.post("/audience_lists/#{URI.escape(list_name)}/add", :body => options.merge(:email => email))
  end

  def remove_from_list(email, list_name)
    self.class.post("/audience_lists/#{URI.escape(list_name)}/remove", :body => {:email => email})
  end

  # TODO: add is_suppressed?
  
  def suppress_email(email)
    self.class.post("/audience_members/#{email}/suppress_email")
  end

  # TODO: add events_since
  
  def suppressed_since(timestamp)
    self.class.get("/audience_members/suppressed_since/#{timestamp.to_s}.txt", :format => :plain)
  end
    
  #
  # Promotions Methods
  # 
  
  def promotions
    self.class.get('/promotions.xml')
  end
  
  # TODO: Search Promotions
  # TODO: Trash Promotions

  def mailing_stats(promotion_id, mailing_id)
    self.class.get("/promotions/#{promotion_id}/mailings/#{mailing_id}.xml")
  end

  private
  
  def build_csv(hash)
    if CSV.respond_to?(:generate_row)   # before Ruby 1.9
      buffer = ''
      CSV.generate_row(hash.keys, hash.keys.size, buffer)
      CSV.generate_row(hash.values, hash.values.size, buffer)
      buffer
    else                               # Ruby 1.9 and after
      CSV.generate do |csv|
        csv << hash.keys
        csv << hash.values
      end
    end
  end
end