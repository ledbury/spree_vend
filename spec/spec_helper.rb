ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "spree_vend"
require "rspec/rails"
require "fabrication"
require "faker"
require 'database_cleaner'
require "hashie"

Dir["./spec/support/**/*.rb"].each { |file| require file }
Dir["./spec/fabricators/**/*.rb"].each { |file| require file }

RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  
end
