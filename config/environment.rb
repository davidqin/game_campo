require 'haml'
require 'sqlite3'
require 'logger'
require 'rack/coffee'
require 'active_record'
require 'pry'

class Object
  def try method_name
    self.send(method_name) if self
    self
  end
end

# connect database
ActiveRecord::Base.logger = Logger.new(File.join(ENV['PWD'], 'log', 'database.log'))
ActiveRecord::Base.configurations = YAML.load_file(File.join(ENV['PWD'], 'config', 'databases.yml'))
ActiveRecord::Base.establish_connection('development')

# load all models
Dir[File.join(ENV['PWD'], 'models', '*.rb')].each {|file| require file }
Dir[File.join(ENV['PWD'], 'models', 'game_engines', '*.rb')].each {|file| require file }

# use ActiveRecord Observer
# Dir[File.join(ENV['PWD'], 'models', 'observers', '*.rb')].each {|file| require file }
# ActiveRecord::Base.add_observer HallObserver.instance

# load all views helper
Dir[File.join(ENV['PWD'], 'helper', '*.rb')].each {|file| require file }

set :views, File.join(ENV['PWD'], 'views')
#set :public_folder, 'public'

# sessions
enable :sessions
set :session_secret, 'super secret'

set :server, 'thin'

# load middlewares
Dir[File.join(ENV['PWD'], 'config', 'middlewares', '*.rb')].each {|file| require file }

# use Sprockets
use SprocketsMiddleware, %r{/assets} do |env|
  env.append_path "assets/css"
  env.append_path "assets/js"
  env.append_path "assets/img"
end
