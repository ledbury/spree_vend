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

### Update Product Inventory in Vend

```ruby
variant = Variant.find(1337)
variant.update_vend_inventory
```

or

```ruby
variant = Variant.find(1337)
product = SpreeVend::Product.new(variant)
product.update
```

### Create Spree user export csv body for Vend

Block is optional.

```ruby
SpreeVend.customer_export_csv do |spree_user|
  # Predicate function; returning true will include the user in the export.
end
```

Example:

```ruby
SpreeVend.customer_export_csv do |spree_user|
  !spree_user.firstname.blank? || !spree_user.lastname.blank?
end
```

### Create Spree variant export csv body for Vend

Block is optional.

```ruby
SpreeVend.product_export_csv do |spree_variant|
  # Predicate function; returning true will include the variant in the export.
end
```

Example:

```ruby
SpreeVend.product_export_csv do |spree_variant|
  spree_variant.name =~ /COPY OF/ || spree_variant.taxons.count == 0
end
```

## To-Do

- Order finalize hooks
- Void sale in Spree when voiding in Vend
