# Spree/Vend Interface

## Configuration

Make a config file in your initializers. Use it thusly:

```ruby
SpreeVend.setup do |config|

  config.vend_store_name = "my_store_subdomain"
  config.vend_username = "my_username"
  config.vend_password = "my_password"
  config.vend_outlet_name = "outlet_name"
  config.vend_discount_product_id = "vend-discount-product-id" # e.g. "k84v3fa7-7916-cj29-08co-bccv53f52a2x"

end
```

## Usage

### *¡Important!* You must manually enter this product in Vend to be able to sync store credits:

- Name: Balance Adjustment (name is arbitrary, but should be descriptive obviously)
- Tax rate: 0
- Price: 0
- No stock tracking

After entering the product, view it and copy its id from the URL. Use this in your spree_vend initializer with the config method `vend_discount_product_id`. It will be used to make balance adjustments.

### Update customer balances in Vend to reflect store credits in Spree

```ruby
SpreeVend::Customer.update_credit_balance_for_all_customers
```

### Update Product Inventory in Vend

```ruby
variant = Variant.find(1337)
variant.update_vend_inventory
```

or

```ruby
variant = Variant.find(1337)
product = SpreeVend::Product.new(variant)
product.update_inventory 5
```

### Create Spree user export csv body for Vend

Pass your desired scope method as a symbol which will be applied to User. Block is optional.

```ruby
SpreeVend.customer_export_csv(:scope_method) do |spree_user|
  # Predicate function; returning true will filter out the user from export.
end
```

Example:

```ruby
SpreeVend.customer_export_csv(:vend_export_scope) do |spree_user|
  spree_user.firstname.blank? || spree_user.lastname.blank?
end
```

### Create Spree variant export csv body for Vend

Pass your desired scope method as a symbol which will be applied to Variant. Block is optional.

```ruby
SpreeVend.product_export_csv(:scope_method) do |spree_variant|
  # Predicate function; returning true will filter out the variant from export.
end
```

Example:

```ruby
SpreeVend.product_export_csv(:vend_export_scope) do |spree_variant|
  spree_variant.name =~ /COPY OF/ || spree_variant.taxons.count == 0
end
```

## To-Do

- Void sale in Spree when voiding in Vend
- Update customer credit in Vend when changed in Spree
- Add new Spree customers (users who purchase) to Vend

## Prerequisites

### Gems

- Curb
- Hashie
- spree_store_credits
