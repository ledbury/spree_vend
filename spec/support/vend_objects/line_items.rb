module VendObjects

  def self.product_line_items
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

  def self.coupon_line_item
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

  def self.shipping_line_item
    Hashie::Mash.new(
      :line_items => [
        {
          quantity: 1,
          price: "10.0",
          name: "Overnight"
        }
      ]
    ).line_items
  end

  def self.shipping_line_items
    Hashie::Mash.new(
      :line_items => [
        {
          quantity: 1,
          price: "10.0",
          name: "Ground"
        },
        {
          quantity: 1,
          price: "10.0",
          name: "Overnight"
        }
      ]
    ).line_items
  end

  def self.adjustment_item
    Hashie::Mash.new(
      :line_items => [
        {
          quantity: 2,
          price: "10.0",
          name: Faker::Product.product_name
        }
      ]
    ).line_items
  end

  def self.tax_adjustment_item
    Hashie::Mash.new(
      :line_items => [
        {
          quantity: 1,
          price: "10.0",
          name: "Virginia Tax"
        }
      ]
    ).line_items
  end

  def self.assortment_of_all_types_of_line_items
    [self.product_line_items, self.coupon_line_item, self.shipping_line_item, self.adjustment_item].flatten
  end

end
