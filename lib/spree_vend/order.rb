class SpreeVend::Order
  attr_accessor :attributes, :spree_order
  attr_reader :vend

  RESOURCE_NAME = "register_sales"

  def initialize(vend_order_id=nil)
    @vend = SpreeVend::Vend.new
    if vend_order_id
      unless @attributes = @vend.get_request("#{RESOURCE_NAME}/#{vend_order_id}").try(:register_sales).try(:first)
        raise VendPosError, "Spree attempted to fetch sale (id #{vend_order_id}) from Vend and it was not found."
      end
    end
  end

  def insert_in_spree
    self.spree_order = ::Order.create
    spree_order.populate_with_vend_sale attributes
    spree_order.finalize_quietly
    spree_order.adjustments.promotion.each do |adj|
      coupon = SpreeVend::Coupon.new(adj.originator.promotion)
      coupon.update
    end
    return true
  end

  def is_balance_adjustment_order?
    attributes.register_sale_products.count == 1 && attributes.register_sale_products.first.product_id == SpreeVend.vend_discount_product_id
  end

  def self.create_store_balance_order(customer_id, amount)
    quantity = 0 <=> amount
    order = {
      :customer_id => customer_id,
      :status => "CLOSED",
      :note => "Account balance adjustment",
      :register_sale_products => [
        {
          :product_id => SpreeVend.vend_discount_product_id,
          :quantity => quantity,
          :price => amount.abs
        }
      ]
    }
    vend = SpreeVend::Vend.new
    vend.post_request RESOURCE_NAME, order.to_json
  end

end
