Rails.application.routes.draw do

  post "/api/hooks/vend/order" => "vend_hooks#order", :as => :order_vend_hook

end
