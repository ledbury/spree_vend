ShippingMethod.class_eval do
  after_save :update_vend_shipping_methods

  def update_vend_shipping_methods
    vend_shipping_method = SpreeVend::ShippingMethod.new self
    vend_shipping_method.update
    SpreeVend::Logger.info "Updated shipping method #{name} in Vend."
    true
  rescue StandardError => e
    SpreeVend::Notification.error e, "Spree failed to update shipping method #{name} on Vend."
    true
  end

end
