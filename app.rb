require 'sinatra'
require 'haml'

require 'active_record'
require 'sqlite3'
require 'logger'

ActiveRecord::Base.logger = Logger.new('debug.log')
ActiveRecord::Base.configurations = YAML.load_file("./config/databases.yml")
ActiveRecord::Base.establish_connection('development')

load './helper/base_helper.rb'

set :views, File.dirname(__FILE__) + "/views"
set :public_folder, 'public'

enable :sessions
set :session_secret, 'super secret'

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

post '/account/login' do
  session[:user_id] = params[:username]
  redirect "/games"
end

get '/account/register' do
  haml :'account/register'
end

def authenticate!
  unless session[:user_id]
    redirect '/account/login'
  end
end

