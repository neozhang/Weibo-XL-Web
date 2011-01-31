%w(sinatra haml oauth sass json timeout weibo).each { |dependency| require dependency }
enable :sessions
# http://open.t.sina.com.cn/apps/1002277584
Weibo::Config.api_key = "2942145647"
Weibo::Config.api_secret = "5cc0026c470a25a6070237e07ade5f27"

get '/' do
  puts
  puts request.env.inspect
  puts
  if session[:atoken]
    redirect "/friends_timeline"
  else
    redirect "/connect"
  end
  haml :index
end

get '/friends_timeline' do
  @timeline = get_timeline
  haml :index
end 

post '/repost/:id' do
  oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
  oauth.authorize_from_access(session[:atoken], session[:asecret])
  Weibo::Base.new(oauth).repost(params[:id])
  redirect '/'
end

post '/fav/:id' do
  oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
  oauth.authorize_from_access(session[:atoken], session[:asecret])
  Weibo::Base.new(oauth).favorites_create(params[:id])
  redirect '/'
end

get '/connect' do
  oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
  request_token = oauth.consumer.get_request_token
  session[:rtoken], session[:rsecret] = request_token.token, request_token.secret
  redirect "#{request_token.authorize_url}&oauth_callback=http://#{request.env["HTTP_HOST"]}/callback"
end

get '/callback' do
  oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
  oauth.authorize_from_request(session[:rtoken], session[:rsecret], params[:oauth_verifier])
  session[:rtoken], session[:rsecret] = nil, nil
  session[:atoken], session[:asecret] = oauth.access_token.token, oauth.access_token.secret
  redirect "/"
end

get '/logout' do
  session[:atoken], session[:asecret] = nil, nil
  redirect "/"
end

get '/screen.css' do
  content_type 'text/css'
  sass :screen
end

def get_timeline()
  oauth = Weibo::OAuth.new(Weibo::Config.api_key, Weibo::Config.api_secret)
  oauth.authorize_from_access(session[:atoken], session[:asecret])
  @timeline = Weibo::Base.new(oauth).friends_timeline()
  return @timeline
end