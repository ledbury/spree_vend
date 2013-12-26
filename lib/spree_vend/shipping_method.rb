class SpreeVend::ShippingMethod
  attr_accessor :price, :name, :spree_shipping_method
  attr_reader :vend

  RESOURCE_NAME = "products"

  def initialize(spree_shipping_method)
    @spree_shipping_method = spree_shipping_method
    @price = @spree_shipping_method.calculator.try(:preferred_amount) or 0
    @name = @spree_shipping_method.name
    @vend = SpreeVend::Vend.new
  end

  def update
    shipping_method = { 
      :sku => name.to_param,
      :handle => name.to_param,
      :name => name,
      :retail_price => price,
      :type => "Shipping",
      :active => 1
    }
    vend.post_request RESOURCE_NAME, shipping_method.to_json
  end

end
