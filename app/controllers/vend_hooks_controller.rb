class VendHooksController < Spree::BaseController

  def order
    payload = SpreeVend.parse_json_response params[:payload]
    # We don't use the payload from Vend's POST for security reasons.
    # Instead, we only use the id from it and fetch the sale data from Vend.
    vend_order = SpreeVend::Order.new payload.id

    # For new orders
    if vend_order.attributes.status == "CLOSED"
      # Prevent duplication of order if Vend POSTs too many times, prevent balance adjustment orders from being placed
        unless Rails.cache.read(SpreeVend.vend_cache_key(payload.id))
          Rails.cache.write(SpreeVend.vend_cache_key(payload.id), true)
          vend_order.insert_in_spree
        end
    end

    render :nothing => true, :status => 202

  rescue StandardError => e
    SpreeVend::Notification.error e, "Error receiving Vend sale."
    render :nothing => true, :status => 202
  end

end
