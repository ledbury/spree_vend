ShippingMethod.class_eval do
  after_save :update_vend_shipping_method

  def update_vend_shipping_method
    SpreeVend::ShippingMethod.new(self).update
    SpreeVend::Logger.info "Updated shipping method #{name} in Vend."
    true
  rescue StandardError => e
    SpreeVend::Notification.error e, "Spree failed to update shipping method #{name} on Vend."
    true
  end

end
