Fabricator(:variant) do
  sku { sequence(:sku, 1) { |i| "sku-#{i}" } }
  is_master true # Eliminates the need for a product
  price 0
end
