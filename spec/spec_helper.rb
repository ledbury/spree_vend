ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "spree_vend"
require "rspec/rails"
require "fabrication"
require "ffaker"
require "database_cleaner"
require "hashie"
require "test-align-centaur"

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
