ENV["RAILS_ENV"] = "test"

# SimpleCov.start must be issued before application code is required.
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/app/controllers/"
  add_filter "/lib/spree_vend/engine.rb"
  add_filter "/lib/spree_vend/exceptions.rb"
end

require "spree_vend"
require "rspec/rails"
require "fabrication"
require "ffaker"
require "database_cleaner"
require "hashie"
require "curb"
require "test-align-centaur"

require File.expand_path("../dummy/config/application.rb",  __FILE__)

Dir["./spec/support/**/*.rb"].each { |file| require file }
Dir["./spec/fabricators/**/*.rb"].each { |file| require file }

RSpec.configure do |config|

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, pre_count: true)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  
end
