User.class_eval do
  
  class << self

    def with_outstanding_credit
      User.joins(:store_credits).where("store_credits.remaining_amount > 0")
    end

    def find_or_create_from_vend_customer(vend_customer)
      User.find_from_vend_customer(vend_customer) || User.create_from_vend_customer(vend_customer)
    end

    def find_from_vend_customer(vend_customer)
      User.find_by_email(vend_customer.email.to_s)
    end

    def create_from_vend_customer(vend_customer)
      u = User.anonymous!
      u.update_attributes(
        :email => vend_customer.email,
        :firstname => vend_customer.name.to_s.split(" ")[0],
        :lastname => vend_customer.name.to_s.split(" ")[1]) unless vend_customer.email.blank?
      return u
    end

  end

end
