class SpreeVend::Product
  attr_accessor :sku, :name, :spree_variant
  attr_reader :vend

  RESOURCE_NAME = "products"

  def initialize(spree_variant)
    @spree_variant = spree_variant
    @sku = @spree_variant.sku
    @name = @spree_variant.name
    @vend = SpreeVend::Vend.new
  end

  def handle
    sku
  end

  # Updates inventory on Vend to reflect count on Spree
  def update_inventory(active_predicate)
    active = spree_variant.respond_to?(active_predicate) ? (spree_variant.send(active_predicate) ? 1 : 0) : 1
    variant_option_one_name =
    variant_option_one_value =
    variant_option_two_name =
    variant_option_two_value =
    variant_option_three_name =
    variant_option_three_value =
    variant_option_four_name =
    variant_option_four_value =
    variant_option_five_name =
    variant_option_five_value = ""
    spree_variant.option_values.each_with_index do |o, i|
      case i
      when 0
        variant_option_one_name = o.option_type.presentation
        variant_option_one_value = o.presentation
      when 1
        variant_option_two_name = o.option_type.presentation
        variant_option_two_value = o.presentation
      when 2
        variant_option_three_name = o.option_type.presentation
        variant_option_three_value = o.presentation
      when 3
        variant_option_four_name = o.option_type.presentation
        variant_option_four_value = o.presentation
      when 4
        variant_option_five_name = o.option_type.presentation
        variant_option_five_value = o.presentation
      end
    end
    product = { 
      :sku => sku,
      :handle => handle,
      :name => name,
      :retail_price => spree_variant.price.to_s,
      :active => (spree_variant.in_stock? ? 1 : 0),
      :tax => SpreeVend.vend_default_tax,
      :variant_option_one_name => variant_option_one_name,
      :variant_option_one_value => variant_option_one_value,
      :variant_option_two_name => variant_option_two_name,
      :variant_option_two_value => variant_option_two_value,
      :variant_option_three_name => variant_option_three_name,
      :variant_option_three_value => variant_option_three_value,
      :variant_option_four_name => variant_option_four_name,
      :variant_option_four_value => variant_option_four_value,
      :variant_option_five_name => variant_option_five_name,
      :variant_option_five_value => variant_option_five_value,
      :inventory => [
        {
          :outlet_name => vend.outlet_name,
          :count => spree_variant.on_hand
        }
      ]
    }
    vend.post_request RESOURCE_NAME, product.to_json
  end

  # Updates all attributes on product in Vend; accepts a Spree variant instance
  def update(spree_variant)
  end

  # Adds a product in Vend; accepts a Spree variant instance
  def add(spree_variant)
  end

end
