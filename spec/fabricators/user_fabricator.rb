Fabricator(:user) do
  email { Faker::Internet.email }
  password { Faker::Lorem.words(3).join("") }
  ship_address { Fabricate(:address) }
  bill_address { Fabricate(:address) }
end
