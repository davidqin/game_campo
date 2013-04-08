require 'yaml'
require 'logger'
require 'active_record'
require "pry"

namespace :db do

  def create_database config
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Base.connection
  end

  task :environment do
    DATABASE_ENV  = ENV['DATABASE_ENV'] || 'development'
    MIGRATIONS_DIR = ENV['MIGRATIONS_DIR'] || 'db/migrate'
  end

  task :configuration => :environment do
    @config = YAML.load_file('config/databases.yml')[DATABASE_ENV]
  end

  task :connection => :configuration do
    ActiveRecord::Base.establish_connection @config
    ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
  end

  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
  task :migrate => :connection do
    ActiveRecord::Migrator.migrate('db/migrations', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc 'Create the database from config/database.yml for the current DATABASE_ENV'
  task :create => :connection do
    if File.exist?(@config['database'])
      puts "#{@config['database']} already exists"
    else
      create_database @config
    end
  end

  desc "create an ActiveRecord migration in ./db/migrations"
  task :create_migration do
    name = ENV['NAME']
    abort("no NAME specified. use `rake db:create_migration NAME=create_users`") if !name

    migrations_dir = File.join("db", "migrations")
    version = ENV["VERSION"] || Time.now.utc.strftime("%Y%m%d%H%M%S")
    filename = "#{version}_#{name}.rb"
    migration_name = name.gsub(/_(.)/) { $1.upcase }.gsub(/^(.)/) { $1.upcase }

    FileUtils.mkdir_p(migrations_dir)

    open(File.join(migrations_dir, filename), 'w') do |f|
      f << (<<-EOS).gsub("      ", "")
      class #{migration_name} < ActiveRecord::Migration
        def self.up
        end

        def self.down
        end
      end
      EOS
    end
  end

  desc "drop development.sqlite3"
  task :drop do
    FileUtils.rm('./db/development.sqlite3')
  end
end