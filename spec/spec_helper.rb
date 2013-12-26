ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "spree_vend"
require "rspec/rails"
require "factory_girl_rails"
require "hashie"

Dir["./spec/support/**/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
