State.class_eval do

  class << self

    def find_from_vend_customer(vend_customer)
      State.find_by_name(vend_customer.physical_state) || State.find_by_abbr(vend_customer.physical_state)
    end

  end

end