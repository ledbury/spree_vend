Variant.class_eval do
  after_save :update_vend_inventory

  def update_vend_inventory
    SpreeVend::Product.new(self).update
    SpreeVend::Logger.info "Updated inventory for #{sku} in Vend."
    true
  rescue StandardError => e
    SpreeVend::Notification.error e, "Spree failed to update inventory on Vend for #{sku} to #{on_hand}."
    true
  end

  # Define in your own Variant model, or not if
  # everything should be active.
  #
  # Should return bool value representing whether the
  # variant should be active in vend or not.
  #
  def active_in_vend?
    true
  end

end
