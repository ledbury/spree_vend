module VendObjects

  def self.line_items
    Hashie::Mash.new(
      :line_items => [
        {
          quantity: 1,
          price: "50.0",
          sku: "sku-1"
        },
        {
          quantity: 2,
          price: "51.0",
          sku: "sku-2"
        },
        {
          quantity: 1,
          price: "10.0",
          sku: "sku-3"
        },
        {
          quantity: 1,
          price: "20.0",
          sku: "sku-3"
        }
      ]
    ).line_items
  end

  def self.coupon_line_items
    Hashie::Mash.new(
      :line_items => [
        {
          quantity: 1,
          price: "-50.0",
          sku: "COUPON-CODE"
        }
      ]
    ).line_items
  end

end
