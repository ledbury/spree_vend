module VendObjects

  def self.taxes
    Hashie::Mash.new(
      :taxes => [
        {
          tax: 5.3,
          name: "Virginia",
          rate: 0.053
        }
      ]
    ).taxes
  end

end
