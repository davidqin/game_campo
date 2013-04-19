require 'sinatra'
require 'sinatra-websocket'
require './config/environment'
require 'json'

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
  if not request.websocket?
    @game = Game.find_by_path!(params[:game_type])
    haml :'/games/hall'
  else
    request.websocket do |websocket|
    end
  end
end

get '/games/:game_type/:custom_string' do
  if not request.websocket?
    @game = Game.find_by_path!(params[:game_type])
    haml :'/games/room'
  else
    request.websocket do |websocket|
      game_engin.handle @current_user, websocket, params[:custom_string]
    end
  end
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

def game_engin
  Class.const_get(params[:game_type].capitalize)
end

def set_current_user
  # magic!
  if request.websocket?
    session[:user_id] = env['rack.session.unpacked_cookie_data']["user_id"]
  end

  return unless session[:user_id]
  @current_user = User.find_by_id(session[:user_id])
end

def authenticate!
  redirect '/account/login' unless @current_user
end