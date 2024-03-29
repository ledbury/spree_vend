Order.class_eval do

  attr_accessor :vend_customer, :vend_sale, :vend_items, :vend_payments

  def populate_with_vend_sale(vend_sale)
    load_vend_sale_object(vend_sale)
    receive_vend_customer
    receive_vend_items
    receive_vend_coupons
    receive_vend_shipping
    receive_vend_adjustments
    receive_vend_tax
    receive_vend_payments
  end

  def finalize_quietly
    self.completed_at = Time.now
    self.state = "complete"
    save(:validate => false)
    InventoryUnit.assign_opening_inventory(self)
    unless line_items.blank? and shipping_method.blank?
      create_shipment!
    end
    state_events.build({
      :previous_state => "cart",
      :next_state     => "complete",
      :name           => "order",
      :user_id        => self.user_id
    })
    if save(:validate => false)
      SpreeVend::Logger.info "Finished finalizing Vend sale as Spree order #{number}."
    end
  end  

  private

  def load_vend_sale_object(vend_sale)
    self.vend_sale = vend_sale
    self.vend_customer = SpreeVend::Vend.get_request("customers?id=#{vend_sale.customer.id}").contact
    self.vend_items = vend_sale.register_sale_products
    self.vend_payments = vend_sale.register_sale_payments
  end

  def receive_vend_customer
    u = User.find_or_create_from_vend_customer(vend_customer)
    address = Address.create_from_vend_customer(vend_customer)
    u.update_attributes_without_callbacks(
      :ship_address_id => address.id,
      :bill_address_id => address.id)
    self.ship_address = address
    self.bill_address = address
    self.user = u
    self.email = u.email
    save(:validate => false)
  end

  def receive_vend_items
    out_of_stock_items = 0
    self.vend_items = self.vend_items.reject do |item|
      if (variant = Variant.find_by_sku(item.sku)) && item.quantity > 0
        out_of_stock_items += 1 if variant.on_hand < 1 || ((variant.on_hand - item.quantity) < 0)
        self.define_singleton_method(:contains?) { |variant| false }
        add_variant(variant, item.quantity).update_attribute(:price, item.price)
      end
    end
    SpreeVend::Notification.info("Vend sale for Spree order #{number} contains #{out_of_stock_items} out of stock item(s).") if out_of_stock_items > 0
  end

  def receive_vend_coupons
    self.vend_items = self.vend_items.reject do |item|
      if promo = Promotion.joins(:stored_preferences).where("preferences.name = ? and preferences.value = ?", "code", item.sku).first
        payload = { :order => self }
        promo.promotion_actions.first.try(:perform, payload) # This bypasses the eligibility check in Promotion#activate
        adjustments.find do |adj|
          adj.originator.promotion.code == promo.code
        end.try(:update_attributes_without_callbacks, {
          :amount => item.price,
          :mandatory => true,
          :eligible => true,
          :locked => true
        })
      end
    end
  end

  def receive_vend_shipping
    if default = SpreeVend.vend_default_shipping_method_name
      unless self.shipping_method = ShippingMethod.find_by_name(default)
        raise VendPosError, "SpreeVend default shipping method is not an available shipping method."
      end
    else
      raise VendPosError, "No default shipping method defined for SpreeVend configuration."
    end
    self.vend_items = self.vend_items.reject do |item|
      if shipping = ShippingMethod.find_by_name(item.name)
        self.shipping_method = shipping
      end
    end
  end

  def receive_vend_adjustments
    self.vend_items.each do |item|
      adjustments.build(
        :label => item.name,
        :amount => (item.quantity.to_i * item.price.to_f)) unless item.name =~ /tax/i
    end
  end

  # Should be refactored to add tax like #receive_vend_coupons
  def receive_vend_tax
    vend_taxes = self.vend_sale.taxes
    manual_taxes = self.vend_sale.register_sale_products.find_all do |adj|
      adj.name =~ /tax/i
    end

    vend_taxes.each do |tax|
      adjustments.build(
        :amount => tax.tax,
        :source => self,
        :originator_type => "TaxRate",
        :label => "#{tax.name} #{tax.rate * 100}%",
        :mandatory => true)
    end unless vend_taxes.blank?

    manual_taxes.each do |item|
      adjustments.build(
        :amount => item.price,
        :source => self,
        :originator_type => "TaxRate",
        :label => "#{item.name}",
        :mandatory => true)
    end unless manual_taxes.blank?

    save(:validate => false)
  end

  def receive_vend_payments
    self.vend_payments.each do |payment|
      payments.build(
        :amount => payment.amount,
        :payment_method_id => PaymentMethod.find_by_name("Vend").id)
    end

    begin
      process_payments!
    rescue StandardError => e
      SpreeVend::Notification.error e, "Could not capture payment for Vend sale."
    end

    save(:validate => false)
  end

end
