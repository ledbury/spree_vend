class SpreeVend::Customer
  attr_accessor :attributes, :spree_user
  attr_reader :vend

  RESOURCE_NAME = "customers"

  def initialize(spree_user)
    @vend = SpreeVend::Vend.new
    @spree_user = spree_user
    @attributes = @vend.get_request("#{RESOURCE_NAME}?email=#{spree_user.email}").customers.try(:first) || create_vend_customer.customer
  end

  def update_vend_customer
    customer = {
      :customer_code => spree_user.try(:email),
      :first_name => spree_user.try(:firstname),
      :last_name => spree_user.try(:lastname),
      :physical_address1 => spree_user.try(:ship_address).try(:address1),
      :physical_address2 => spree_user.try(:ship_address).try(:address2),
      :physical_city => spree_user.try(:ship_address).try(:city),
      :physical_postcode => spree_user.try(:ship_address).try(:zipcode),
      :physical_state => spree_user.try(:ship_address).try(:state_text),
      :physical_country_id => spree_user.try(:ship_address).try(:country).try(:iso),
      :phone => spree_user.try(:ship_address).try(:phone),
      :email => spree_user.try(:email)
    }
    vend.post_request RESOURCE_NAME, customer.to_json
  end
  alias :create_vend_customer :update_vend_customer

end
