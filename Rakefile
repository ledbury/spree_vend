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

desc 'Print out all defined routes in match order, with names.'
task :routes do
  require File.expand_path("../lib/spree_vend",  __FILE__)
  # SpreeVend::Engine.reload_routes!
  all_routes = SpreeVend::Engine.routes.routes

  routes = all_routes.collect do |route|

    reqs = route.requirements.dup
    reqs[:to] = route.app unless route.app.class.name.to_s =~ /^ActionDispatch::Routing/
    reqs = reqs.empty? ? "" : reqs.inspect

    {:name => route.name.to_s, :verb => route.verb.to_s, :path => route.path, :reqs => reqs}
  end

   # Skip the route if it's internal info route
  routes.reject! { |r| r[:path] =~ %r{/rails/info/properties|^/assets} }

  name_width = routes.map{ |r| r[:name].length }.max
  verb_width = routes.map{ |r| r[:verb].length }.max
  path_width = routes.map{ |r| r[:path].length }.max

  routes.each do |r|
    puts "#{r[:name].rjust(name_width)} #{r[:verb].ljust(verb_width)} #{r[:path].ljust(path_width)} #{r[:reqs]}"
  end
end
