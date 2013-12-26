shared_context "an anonymous user" do
  let(:vend_customer) do
    Hashie::Mash.new({
      first_name: "",
      last_name: "",
      phone: "",
      email: "",
      physical_address1: "",
      physical_address2: "",
      physical_city: "",
      physical_state: "",
      physical_postcode: "",
      physical_country_id: ""
    })
  end
end

shared_context "a user with an invalid address" do
  let(:vend_customer) do
    Hashie::Mash.new({
      first_name: "hugh",
      last_name: "jass",
      phone: "123-456-7890",
      email: "hughjass@example.com",
      physical_address1: "123 fake st",
      physical_address2: "",
      physical_city: "Richmond",
      physical_state: "",
      physical_postcode: "",
      physical_country_id: "US"
    })
  end
end

shared_context "a user with all required info" do
  let(:vend_customer) do
    Hashie::Mash.new({
      first_name: "hugh",
      last_name: "jass",
      phone: "123-456-7890",
      email: "hughjass@example.com",
      physical_address1: "123 fake st",
      physical_address2: "",
      physical_city: "Richmond",
      physical_state: "VA",
      physical_postcode: "23219",
      physical_country_id: "US"
    })
  end
end
