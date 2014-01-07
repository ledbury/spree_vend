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

end
