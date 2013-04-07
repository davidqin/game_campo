require 'sinatra'
require 'haml'

load './helper/base_helper.rb'

set :views, File.dirname(__FILE__) + "/views"
set :public_folder, 'public'

enable :session
set    :session_secret,      'super secret'
set    :sessions, :domain => 'foo.com'

before %r{^\/games} do
  authenticate!
end

get '/' do
  haml :index
end

get '/games' do
  haml :'/games/index'
end

get '/account/login' do
  haml :'account/login'
end

get '/account/register' do
  haml :'account/register'
end

def authenticate!
  unless session[:user_id]
    redirect '/account/login'
  end
end

