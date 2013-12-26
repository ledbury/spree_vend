Variant.class_eval do
  after_save :update_vend_inventory

  def update_vend_inventory
    vend_product = SpreeVend::Product.new self
    vend_product.update_inventory(:vend_product_active_predicate)
    SpreeVend::Logger.info "Updated inventory for #{sku} in Vend."
    true
  rescue StandardError => e
    SpreeVend::Notification.error e, "Spree failed to update inventory on Vend for #{sku} to #{on_hand}."
    true
  end

end
