Order.class_eval do

  attr_accessor :vend_customer, :vend_order, :vend_items, :vend_payments

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
    self.shipping_method ||= ShippingMethod.find_by_name(SpreeVend.vend_default_shipping_method_name)
    self.completed_at = Time.now
    self.state = "complete"
    save(:validate => false)
    track! :complete_orders
    InventoryUnit.assign_opening_inventory(self)
    consume_users_credit
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
    self.vend_customer = SpreeVend::Vend.new.get_request("customers?id=#{vend_sale.customer.id}").contact
    self.vend_order = vend_sale
    self.vend_items = vend_sale.register_sale_products
    self.vend_payments = vend_sale.register_sale_payments
  end

  def receive_vend_customer
    u = User.find_or_create_from_vend_customer(vend_customer)
    if address = Address.create_from_vend_customer(vend_customer)
      u.update_attributes_without_callbacks(
        :ship_address_id => address.id,
        :bill_address_id => address.id)
      self.ship_address = address
      self.bill_address = address
    else
      SpreeVend::Notification.info "Vend sale for Spree order #{number} contains no address, but it may not need one."
    end
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
    @vend_line_items = @vend_line_items.reject do |item|
      self.shipping_method = ShippingMethod.find_by_name(item.name)
    end
  end

  def receive_vend_adjustments
    @vend_line_items.each do |item|
      adjustments.build(
        :label => item.name,
        :amount => (item.quantity.to_i * item.price.to_f)) unless item.name =~ /tax/i
    end
  end

  # We don't use a spree TaxRate object as the originator so we can force the vend-calculated tax amounts
  def receive_vend_tax
    vend_order = @vend_order_attributes
    vend_taxes = vend_order.taxes
    manual_taxes = vend_order.register_sale_products.find_all do |adj|
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
    vend_payments = @vend_payments
    update_totals

    # Apply normal payments
    vend_payments.each do |payment|
      payments.build(
        :amount => payment.amount,
        :payment_method_id => PaymentMethod.find_by_name("Vend").id)
    end

    # Process payments
    begin
      process_payments!
    rescue StandardError => e
      SpreeVend::Notification.error e, "Could not capture payment for Vend sale, corresponding Spree order #{number}."
    end

    update!
  end

end
