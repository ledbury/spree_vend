class SpreeVend::Product
  attr_accessor :spree_variant

  RESOURCE_NAME = "products"

  def initialize(spree_variant)
    @spree_variant = spree_variant
  end

  def handle
    spree_variant.sku
  end

  def active?
    spree_variant.active_in_vend? ? 1 : 0
  end

  def update
    product = { 
      :sku => spree_variant.sku,
      :handle => handle,
      :name => spree_variant.name,
      :retail_price => spree_variant.price.to_s,
      :active => active?,
      :tax => SpreeVend.vend_default_tax,
      :inventory => [
        {
          :outlet_name => SpreeVend.vend_outlet_name,
          :count => spree_variant.on_hand
        }
      ]
    }
    spree_variant.option_values.each_with_index do |o, i|
      product["variant_option_#{%w(one two three four five six)[i]}_name"] = o.option_type.presentation
      product["variant_option_#{%w(one two three four five six)[i]}_value"] = o.presentation
    end

    SpreeVend::Vend.post_request RESOURCE_NAME, product.to_json
  end

end
