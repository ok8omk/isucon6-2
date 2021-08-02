require 'json'
require 'net/http'
require 'uri'

require 'mysql2'
require 'mysql2-cs-bind'
require 'rack/utils'
require 'sinatra/base'

module Isutar
  class Web < ::Sinatra::Base
    enable :protection

    set :db_user, ENV['ISUTAR_DB_USER'] || 'root'
    set :db_password, ENV['ISUTAR_DB_PASSWORD'] || ''
    set :dsn, ENV['ISUTAR_DSN'] || 'dbi:mysql:db=isutar'
    set :isuda_origin, ENV['ISUDA_ORIGIN'] || 'http://localhost:5000'

    configure :development do
      require 'sinatra/reloader'

      register Sinatra::Reloader
    end

    helpers do
      def db
        Thread.current[:db] ||=
          begin
            _, _, attrs_part = settings.dsn.split(':', 3)
            attrs = Hash[attrs_part.split(';').map {|part| part.split('=', 2) }]
            mysql = Mysql2::Client.new(
              username: settings.db_user,
              password: settings.db_password,
              database: attrs['db'],
              encoding: 'utf8mb4',
              init_command: %|SET SESSION sql_mode='TRADITIONAL,NO_AUTO_VALUE_ON_ZERO,ONLY_FULL_GROUP_BY'|,
            )
            mysql.query_options.update(symbolize_keys: true)
            mysql
          end
      end
    end

    get '/initialize' do
      content_type :json
      JSON.generate(result: 'ok')
    end
  end
end
