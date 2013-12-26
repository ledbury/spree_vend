Address.class_eval do

  class << self

    def create_from_vend_customer(vend_customer)
      addr = Address.new(Address.build_address_hash_from_vend_customer(vend_customer))
      if addr && addr.save(:validate => false)
        SpreeVend::Notification.info "Vend sale may contain an invalid address." unless addr.valid?
        addr
      else
        nil
      end
    end

    def build_address_hash_from_vend_customer(vend_customer)
      {
        :firstname => vend_customer.first_name,
        :lastname => vend_customer.last_name,
        :address1 => vend_customer.physical_address1,
        :address2 => vend_customer.physical_address2,
        :city => vend_customer.physical_city,
        :zipcode => vend_customer.physical_postcode,
        :state => State.find_from_vend_customer(vend_customer),
        :country => Country.find_by_iso(vend_customer.physical_country_id),
        :phone => vend_customer.phone
      }
    end

  end
  
end