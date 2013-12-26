module VendRequest

  class << self

    def get_register_sale
      f = File.open("spec/support/json/vend_order.json", "r")
      string = f.read
      f.close
      return SpreeVend.parse_json_response string
    end

    def get_customer
      f = File.open("spec/support/json/vend_customer.json", "r")
      string = f.read
      f.close
      return SpreeVend.parse_json_response string
    end

  end

end
