require 'sinatra'
require 'haml'
require 'sqlite3'
require 'logger'
require 'rack/coffee'
require 'active_record'

# connect database
ActiveRecord::Base.logger = Logger.new(File.join(ENV['PWD'], 'log', 'database.log'))
ActiveRecord::Base.configurations = YAML.load_file(File.join(ENV['PWD'], 'config', 'databases.yml'))
ActiveRecord::Base.establish_connection('development')

# load all models
Dir[File.join(ENV['PWD'], 'models', '*.rb')].each {|file| require file }

# serve coffee-script
use Rack::Coffee, root: 'public', urls: '/js'

# load all views helper
Dir[File.join(ENV['PWD'], 'helper', '*.rb')].each {|file| require file }

set :views, File.join(ENV['PWD'], 'views')
set :public_folder, 'public'

# sessions
enable :sessions
set :session_secret, 'super secret'