# encoding: UTF-8

require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must run `gem install bundler` and `bundle install` to run rake tasks'
end
require 'rake'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

desc "Generates a dummy app for testing"
namespace :common do
  task :test_app do
    require File.expand_path("../lib/spree_vend",  __FILE__)

    Spree::DummyGenerator.start ["--lib_name=spree_vend", "--database=sqlite3", "--quiet"]
    Spree::SiteGenerator.start ["--lib_name=spree_vend", "--quiet"]
    puts "Setting up dummy database..."
    cmd = "bundle exec rake db:drop db:create db:migrate db:seed RAILS_ENV=test AUTO_ACCEPT=true"
    if RUBY_PLATFORM =~ /mswin/ #windows
      cmd += " >nul"
    else
      cmd += " >/dev/null"
    end

    system(cmd)
  end
end

