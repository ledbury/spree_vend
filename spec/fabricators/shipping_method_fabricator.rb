Fabricator(:shipping_method) do
  zone { Zone.all.empty? ? Fabricate(:zone) : Zone.first }
  calculator { Fabricate.build(:flat_rate_calculator) }
end
