module SpreeVend

  class << self

    def parse_json_response(response)
      Hashie::Mash.new JSON.parse(response)
    end

    def vend_cache_key(sale_id)
      "vend_sale_#{sale_id}"
    end

    def generate_csv(rows)
      CSV.generate do |csv|
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
        :company_name,
        :postal_address1,
        :postal_address2,
        :postal_suburb,
        :postal_city,
        :postal_postcode,
        :postal_state,
        :postal_country_id,
        :physical_address1,
        :physical_address2,
        :physical_suburb,
        :physical_city,
        :physical_postcode,
        :physical_state,
        :physical_country_id,
        :phone,
        :fax,
        :mobile,
        :website,
        :email,
        :customer_group_name,
        :note,
        :custom_field_1,
        :custom_field_2,
        :custom_field_3,
        :custom_field_4
      ]
      rows << csv_columns
      ::User.send(scope).each do |user|
        unless (block_given? ? yield(user) : false)
          rows << [
            user.email,
            user.firstname,
            user.lastname,
            "",
            user.try(:ship_address).try(:address1),
            user.try(:ship_address).try(:address2),
            "",
            user.try(:ship_address).try(:city),
            user.try(:ship_address).try(:zipcode),
            user.try(:ship_address).try(:state_text),
            user.try(:ship_address).try(:country).try(:iso),
            user.try(:ship_address).try(:address1),
            user.try(:ship_address).try(:address2),
            "",
            user.try(:ship_address).try(:city),
            user.try(:ship_address).try(:zipcode),
            user.try(:ship_address).try(:state_text),
            user.try(:ship_address).try(:country).try(:iso),
            user.try(:ship_address).try(:phone),
            "",
            "",
            "",
            user.email,
            "",
            "",
            "",
            "",
            "",
            ""
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
        :variant_option_five_value
      ]
      rows << csv_columns
      ::Variant.send(scope).each do |variant|
        unless (block_given? ? yield(variant) : false)
          available = variant.respond_to?(:vend_product_active_predicate) ? (variant.vend_product_active_predicate ? 1 : 0) : 1
          variant_option_one_name =
          variant_option_one_value =
          variant_option_two_name =
          variant_option_two_value =
          variant_option_three_name =
          variant_option_three_value =
          variant_option_four_name =
          variant_option_four_value =
          variant_option_five_name =
          variant_option_five_value = ""
          variant.option_values.each_with_index do |o, i|
            case i
            when 0
              variant_option_one_name = o.option_type.presentation
              variant_option_one_value = o.presentation
            when 1
              variant_option_two_name = o.option_type.presentation
              variant_option_two_value = o.presentation
            when 2
              variant_option_three_name = o.option_type.presentation
              variant_option_three_value = o.presentation
            when 3
              variant_option_four_name = o.option_type.presentation
              variant_option_four_value = o.presentation
            when 4
              variant_option_five_name = o.option_type.presentation
              variant_option_five_value = o.presentation
            end
          end
          rows << [
            variant.sku,
            variant.sku,
            variant.name,
            variant.price.to_s,
            1,
            (variant.on_hand || 0),
            available,
            SpreeVend.vend_default_tax,
            variant_option_one_name,
            variant_option_one_value,
            variant_option_two_name,
            variant_option_two_value,
            variant_option_three_name,
            variant_option_three_value,
            variant_option_four_name,
            variant_option_four_value,
            variant_option_five_name,
            variant_option_five_value
          ]
        end
      end
      self.generate_csv(rows)
    end

  end

end
