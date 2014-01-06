Fabricator(:user) do
  email Faker::Internet.email
  shipping_address { Fabricate(:address) }
  billing_address { Fabricate(:address) }
end
