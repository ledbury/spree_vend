module VendObjects

  def self.register_sale
    Hashie::Mash.new(
      customer: { id: "yada-yada-yada" },
      register_sale_products: VendObjects.product_line_items,
      taxes: VendObjects.taxes,
      register_sale_payments: VendObjects.payments
    )
  end

end
