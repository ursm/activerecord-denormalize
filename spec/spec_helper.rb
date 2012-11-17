$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'bundler/setup'

require 'rspec'
require 'rspec/autorun'

require 'active_record'
require 'activerecord-postgres-hstore/activerecord'

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

config = {
  adapter:      'postgresql',
  database:     'activerecord-denormalize',
  username:     'postgres',
  min_messages: 'warning'
}

ActiveRecord::Base.establish_connection config.merge(database: 'postgres', schema_search_path: 'public')
ActiveRecord::Base.connection.recreate_database config[:database]
ActiveRecord::Base.establish_connection config

class SetupMigration < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS hstore'

    create_table :messages do |t|
      t.references :sender, polymorphic: true
      t.hstore     :_sender
    end

    create_table :users do |t|
      t.string :name
    end
  end
end

ActiveRecord::Migration.verbose = false
SetupMigration.new.up

require 'activerecord-denormalize'

class Message < ActiveRecord::Base
  belongs_to :sender, polymorphic: true
  serialize :_sender, ActiveRecord::Coders::Hstore
end

class User < ActiveRecord::Base
  has_many :messages, as: :sender, denormalize: {
    attributes: [:name]
  }
end
