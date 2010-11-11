require 'fakeweb'

FakeWeb.allow_net_connect = false

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/../fixtures/' + filename)
  File.read(file_path)
end

def madmimi_url(url, https = false)  
  url+= url.include?("?") ? "&" : "?"
  url+= "username=email%40example.com&api_key=testapikey"
  
  if https == false
    url =~ /^http/ ? url : "http://api.madmimi.com#{url}"
  else
    url =~ /^https/ ? url : "https://api.madmimi.com#{url}"
  end
  
end

def stub_get(url, filename, https = false, status = nil)
  options = { :body => fixture_file(filename) }
  options.merge!({ :status => status }) unless status.nil?
  FakeWeb.register_uri(:get, madmimi_url(url, https), options)
end

# In the process of tweaking this. - Nicholas
def stub_post(url, filename = nil, https = false, status = nil)
  options = { :body => "" }
  options.merge!({ :status => status }) unless status.nil?
  FakeWeb.register_uri(:post, madmimi_url(url, https), options)
end

def stub_delete(url, filename = nil, https = false, status = nil)
  options = { :body => "" }
  options.merge!({ :status => status }) unless status.nil?
  FakeWeb.register_uri(:delete, madmimi_url(url, https), options)
end