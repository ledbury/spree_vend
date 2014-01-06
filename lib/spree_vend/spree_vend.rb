module SpreeVend

  class << self

    def parse_json_response(response)
      Hashie::Mash.new(JSON.parse(response))
    end

    def vend_cache_key(sale_id)
      "vend_sale:#{sale_id}"
    end

    def generate_csv(rows)
      unless rows.kind_of?(Array) and rows.try(:first).kind_of?(Array) and rows.try(:first).try(:first).kind_of?(String)
        raise(TypeError, "The argument received by .generate_csv should be an Array[Array[String]]")
      end
      CSV.generate force_quotes: true do |csv|
        rows.each do |row|
          csv << row
        end
      end
    end

    def customer_export_csv(scope)
      rows = []
      csv_columns = [
        :customer_code,
        :first_name,
        :last_name,
        :physical_address1,
        :physical_address2,
        :physical_city,
        :physical_postcode,
        :physical_state,
        :physical_country_id,
        :phone,
        :email
      ]
      rows << csv_columns
      User.send(scope).each do |user|
        if (block_given? ? !yield(variant) : true)
          rows << [
            user.email,
            user.firstname,
            user.lastname,
            user.try(:ship_address).try(:address1),
            user.try(:ship_address).try(:address2),
            user.try(:ship_address).try(:city),
            user.try(:ship_address).try(:zipcode),
            user.try(:ship_address).try(:state_text),
            user.try(:ship_address).try(:country).try(:iso),
            user.try(:ship_address).try(:phone),
            user.email
          ]
        end
      end
      self.generate_csv(rows)
    end

    def product_export_csv(scope)
      rows = []
      csv_columns = [
        :handle, # product name parameterized; unique to product, common among product variants
        :sku,
        :name, # product name humanized
        :retail_price,
        :track_inventory, # boolean; 1 for yes, 0 for no
        :inventory_hq, # key is inventory_{outlet name}, value is inventory count
        :active, # boolean; 1 for yes, 0 for no
        :tax, # tax setting for product
        :variant_option_one_name,
        :variant_option_one_value,
        :variant_option_two_name,
        :variant_option_two_value,
        :variant_option_three_name,
        :variant_option_three_value,
        :variant_option_four_name,
        :variant_option_four_value,
        :variant_option_five_name,
        :variant_option_five_value,
        :variant_option_six_name,
        :variant_option_six_value
      ]
      rows << csv_columns
      Variant.send(scope).each do |variant|
        if (block_given? ? !yield(variant) : true)
          row << [
            variant.sku,
            variant.sku,
            variant.name,
            variant.price.to_s,
            1,
            (variant.on_hand || 0),
            (variant.active_in_vend? ? 1 : 0),
            SpreeVend.vend_default_tax
          ]
          variant.option_values.each do |o|
            row << o.option_type.presentation
            row << o.presentation
          end
          rows << row
        end
      end
      self.generate_csv(rows)
    end

  end

end
