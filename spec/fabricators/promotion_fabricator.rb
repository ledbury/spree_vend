Fabricator(:flat_rate_calculator, class_name: "Calculator::FlatRate") do
  preferred_amount 10.0
end

Fabricator(:create_adjustment_action, class_name: "Promotion::Actions::CreateAdjustment") do
  initialize_with { Promotion::Actions::CreateAdjustment.create }
  calculator { Fabricate.build(:flat_rate_calculator) }
end

Fabricator(:promotion) do
  name "COUPON-CODE"
  code "COUPON-CODE"
  usage_limit 0 # no limit
  expires_at Time.now.yesterday # ensure eligible? to be false
  event_name "spree.checkout.coupon_code_added"
  promotion_actions { [Fabricate(:create_adjustment_action)] }
end
