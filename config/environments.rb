require 'sinatra'

configure :development do
  ENV['DATABASE_URL'] = 'sqlite://db/dev.db'
end

configure :test do
  ENV['DATABASE_URL'] = 'sqlite://db/test.db'
end

configure :development, :test do
  require 'config_env'
  ConfigEnv.path_to_config("#{__dir__}/config_env.rb")
  require 'hirb'
  Hirb.enable
end

configure do
  enable :logging
  require 'sequel'
  DB = Sequel.connect(ENV['DATABASE_URL'])
end
