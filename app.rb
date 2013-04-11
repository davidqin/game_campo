require 'sinatra'
require './config/environment'

before %r{^\/} do
  set_current_user
end

before %r{^\/games} do
  authenticate!
end

get '/' do
  haml :index
end

get '/games' do
  haml :'/games/index'
end

get '/games/:game_type' do
  @game = Game.find_by_path!(params[:game_type])
  haml :'/games/hall'
end

get '/account/login' do
  haml :'account/login'
end

post '/account/login' do
  email = params[:user][:email]
  encrypted_password = User.encrypt_password(params[:user][:password])
  user = User.find_by_email_and_encrypted_password(email, encrypted_password)
  if user
    session[:user_id] = user.id
    @current_user = user
    redirect "/games"
  else
    haml :'account/login'
  end
end

get '/account/register' do
  @user = User.new
  haml :'account/register'
end

post '/account/register' do
  @user = User.new(params[:user])
  if @user.save
    session[:user_id] = @user.id
    @current_user = @user
    redirect "/games"
  else
    @errors = @user.errors.messages
    haml :'account/register'
  end
end

def set_current_user
  return unless session[:user_id]
  @current_user = User.find_by_id(session[:user_id])
end

def authenticate!
  redirect '/account/login' unless @current_user
end