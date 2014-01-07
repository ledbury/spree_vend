module SpreeVend

  mattr_accessor :vend_store_name
  mattr_accessor :vend_username
  mattr_accessor :vend_password
  mattr_accessor :vend_outlet_name
  mattr_accessor :vend_discount_product_id
  mattr_accessor :vend_default_tax
  mattr_accessor :vend_default_shipping_method_name
  mattr_accessor :cacert_path
  mattr_accessor :info_recipients
  mattr_accessor :error_recipients

  def self.setup
    yield self
  end

  class Engine < Rails::Engine
    engine_name "spree_vend"

    config.autoload_paths += %W(#{config.root}/lib)

    routes.draw do
      post "/api/hooks/vend/order", to: "vend_hooks#order"
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end

end
