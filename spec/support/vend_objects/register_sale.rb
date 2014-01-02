module VendObjects

  def self.register_sale
    Hashie::Mash.new(
      register_sale_products: VendObjects.product_line_items,
      taxes: VendObjects.taxes
    )
  end

end
