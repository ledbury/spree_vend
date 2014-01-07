Fabricator(:address) do
  firstname { Faker::Name.first_name }
  lastname { Faker::Name.last_name }
  address1 { Faker::Address.street_address }
  city { Faker::Address.city }
  zipcode { Faker::AddressUS.zip_code }
  phone { Faker::PhoneNumber.phone_number }
  state
  country { Country.all.empty? ? Fabricate(:country) : Country.first }
end
