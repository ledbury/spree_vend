Fabricator(:vend_payment_method, :class_name => :payment_method) do
  name "Vend"
  type "PaymentMethod::Check"
end
