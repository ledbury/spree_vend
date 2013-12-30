Fabricator(:variant) do
  sku { sequence(:sku, 1) { |i| "sku-#{i}" } }
  name { Faker::Commerce.product_name }
end
