class SpreeVend::Coupon
  attr_reader :code, :name, :spree_promotion

  RESOURCE_NAME = "products"

  def initialize(spree_promotion)
    @spree_promotion = spree_promotion
    @code = @spree_promotion.code
    @name = @spree_promotion.name
  end

  def update
    active = !spree_promotion.expired? && spree_promotion.preferred_usage_limit > spree_promotion.credits.count
    coupon = { 
      :sku => code,
      :handle => code,
      :type => "Coupon",
      :active => (active ? 1 : 0)
    }
    SpreeVend::Vend.post_request RESOURCE_NAME, coupon.to_json
  end

end
