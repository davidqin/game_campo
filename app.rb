require 'sinatra'
require 'sinatra-websocket'
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
  if not request.websocket?
    haml :'/games/hall'
  else
    request.websocket do |ws|
      @channel ||= Channel.find_or_create(env['PATH_INFO'])

      ws.onopen do
        @channel.add(ws)
      end

      ws.onmessage do |msg|
        # EM.next_tick { @channel.members.each{|s| s.send(msg) } }
      end

      ws.onclose do
        @channel.del(ws)
      end
    end
  end
end

get '/games/:game_type/:room_number' do
  @game = Game.find_by_path!(params[:game_type])
  @room = @game.rooms.find_by_number!(params[:room_number])

  if not request.websocket?
    haml :'/games/room'
  else
    request.websocket do |ws|
      @channel ||= Channel.find_or_create(env['PATH_INFO'])

      ws.onopen do
        @channel.add(ws)
      end

      ws.onmessage do |msg|
        puts msg
        # EM.next_tick { @channel.members.each{|s| s.send(msg) } }
      end

      ws.onclose do
        @channel.del(ws)
      end
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