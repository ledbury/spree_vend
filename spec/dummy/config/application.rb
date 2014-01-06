require 'rails/all'
require 'spree_vend'
require 'spree_promo'

module Dummy
  class Application < Rails::Application
  end
end

Dummy::Application.configure do
  config.session_store :cookie_store, :key => '_dummy_session'
  config.secret_token = '4717590662650b7c2d7b098bad5ad65016c8049437381fbd9e8aa78eb28f5ac7d6b4e2799e824d91a7f933a750464910d5177a1c3beb45f0fee1ab619833f3f0'
  config.cache_classes = true
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"
  config.whiny_nils = true
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false
  config.action_mailer.delivery_method = :test
  config.active_support.deprecation = :silence
end

# Enable parameter wrapping for JSON. You can disable this by setting :format to an empty array.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters :format => [:json]
end

# Disable root element in JSON by default.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end

Dummy::Application.initialize!

Rails.application.routes.draw do
  mount SpreeVend::Engine => "/"
end

ActiveRecord::Base.include_root_in_json = true
