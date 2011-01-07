require 'sinatra'
require 'rubygems'
require 'haml'
gem 'oauth'
require 'oauth/consumer'

# Create a Weibo oauth instance for authorization process
# http://open.t.sina.com.cn/apps/1002277584
api_key = '1002277584'
api_key_secret = '5e7fac721cda71ce62247a6f48316487'

get '/' do
  haml :index
end

get '/connect' do
  # here to allow users to connect to their Sina Weibo accounts
  @consumer = OAuth::Consumer.new(api_key, api_key_secret,
                                   {:site => "http://api.t.sina.com.cn",
                                    :request_token_path=>"/oauth/request_token",  
                                    :access_token_path=>"/oauth/access_token",  
                                    :authorize_path=>"/oauth/authorize",  
                                    :signature_method=>"HMAC-SHA1",  
                                    :scheme=>:header
                                   }
                                 )
  @request_token=@consumer.get_request_token
  redirect @request_token.authorize_url
  @access_token=@request_token.get_access_token
end



