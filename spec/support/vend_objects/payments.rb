module VendObjects

  def self.payments
    Hashie::Mash.new({
      :payments => [
        { amount: 75.25 },
        { amount: 24.75 }
      ]
    }).payments
  end

end
