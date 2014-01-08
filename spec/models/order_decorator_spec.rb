require "spec_helper"

describe Order do

  before(:each) { Variant.any_instance.stub(:update_vend_inventory).and_return(true) }

  describe "#populate_with_vend_sale" do

    before(:all) do
      Fabricate(:country)
      Fabricate(:state)
      Fabricate(:shipping_method, name: "Ground")
      Fabricate(:shipping_method, name: "Overnight")
    end

    before(:each) do
      SpreeVend::Vend.
        stub(:get_request).
        with("customers?id=#{VendObjects.register_sale.customer.id}").
        and_return(vend_customer)
      SpreeVend.vend_default_shipping_method_name = "Ground"
      Fabricate(:vend_payment_method)
      Fabricate.times(3, :variant)
      Fabrication::Sequencer.reset
    end

    let(:vend_sale) { VendObjects.register_sale }
    let(:vend_customer) { VendObjects.customer }

    subject(:order) do
      Order.create
    end

    it "completes procedure without error" do
      expect { order.populate_with_vend_sale(vend_sale) }.not_to raise_error
    end

  end

  describe "#finalize_quietly" do

    before(:all) do
      Fabricate(:country)
      Fabricate(:state)
      Fabricate(:shipping_method, name: "Ground")
      Fabricate(:shipping_method, name: "Overnight")
    end

    before(:each) do
      SpreeVend::Vend.
        stub(:get_request).
        with("customers?id=#{VendObjects.register_sale.customer.id}").
        and_return(vend_customer)
      SpreeVend.vend_default_shipping_method_name = "Ground"
      Fabricate(:vend_payment_method)
      Fabricate.times(3, :variant)
      Fabrication::Sequencer.reset
    end

    let(:vend_sale) { VendObjects.register_sale }
    let(:vend_customer) { VendObjects.customer }

    subject(:order) do
      Order.create.tap do |o|
        o.populate_with_vend_sale(vend_sale)
      end
    end

    it "sets completed at time to current time" do
      order.finalize_quietly
      expect(order.completed_at.to_i).to be_within(10).of(Time.now.to_i)
    end

    it "sets state to complete" do
      order.finalize_quietly
      expect(order.state).to eql("complete")
    end

    it "creates shipments" do
      order.finalize_quietly
      expect(order.shipments).not_to be_empty
    end

    it "logs success message" do
      expect(SpreeVend::Logger).to receive(:info).with(an_instance_of(String)).at_least(:once)
      order.finalize_quietly
    end

  end

  describe "#load_vend_sale_object" do

    before(:each) do
      SpreeVend::Vend.
        stub(:get_request).
        with("customers?id=#{VendObjects.register_sale.customer.id}").
        and_return(vend_customer)
    end

    let(:vend_sale) { VendObjects.register_sale }
    let(:vend_customer) { VendObjects.customer }

    subject(:order) do
      Order.create.tap do |o|
        o.send(:load_vend_sale_object, vend_sale)
      end
    end

    it "assigns vend customer to vend_customer attribute" do
      expect(order.vend_customer).to eql(vend_customer.contact)
    end

    it "assigns vend sale to vend_sale attribute" do
      expect(order.vend_sale).to eql(vend_sale)
    end

    it "assigns vend items to vend_items attribute" do
      expect(order.vend_items).to eql(vend_sale.register_sale_products)
    end

    it "assigns vend payments to vend_payments attribute" do
      expect(order.vend_payments).to eql(vend_sale.register_sale_payments)
    end

  end

  describe "#receive_vend_customer" do

    before(:all) do
      Fabricate(:country)
      Fabricate(:state)
    end

    subject(:order) do
      Order.create.tap do |o|
        o.vend_customer = vend_customer
        o.send(:receive_vend_customer)
      end
    end

    context "with an anonymous user" do
      let(:vend_customer) { VendObjects.anonymous_customer.contact }
      include_examples "receives a vend customer"

      it "creates anonymous user" do
        expect(order.user.anonymous?).to be_true
      end

      it "fires notification of invalid address" do
        expect(SpreeVend::Notification).to receive(:info).with(an_instance_of(String)).at_least(:once)
        order.send(:receive_vend_customer)
      end
    end

    context "with a bad address" do
      let(:vend_customer) { VendObjects.invalid_address_customer.contact }
      include_examples "receives a vend customer"

      it "saves address as ship address for user and order" do
        expect(order.reload.ship_address.address1).to eql(vend_customer.physical_address1)
        expect(order.reload.user.ship_address.address1).to eql(vend_customer.physical_address1)
      end

      it "saves address as bill address for user and order" do
        expect(order.reload.bill_address.address1).to eql(vend_customer.physical_address1)
        expect(order.reload.user.bill_address.address1).to eql(vend_customer.physical_address1)
      end
    end

    context "with all required info" do
      let(:vend_customer) { VendObjects.customer.contact }
      include_examples "receives a vend customer"

      it "saves address as ship address for user and order" do
        expect(order.reload.ship_address.address1).to eql(vend_customer.physical_address1)
        expect(order.reload.user.ship_address.address1).to eql(vend_customer.physical_address1)
      end

      it "saves address as bill address for user and order" do
        expect(order.reload.bill_address.address1).to eql(vend_customer.physical_address1)
        expect(order.reload.user.bill_address.address1).to eql(vend_customer.physical_address1)
      end
    end

  end

  describe "#receive_vend_items" do

    before(:each) do
      Fabricate.times(3, :variant)
      Fabrication::Sequencer.reset
    end

    let(:vend_items) { VendObjects.product_line_items }

    subject(:order) do
      Order.create.tap do |o|
        o.vend_items = vend_items
        o.send(:receive_vend_items)
      end
    end

    it "adds line item to order for each line item from vend" do
      expect(order.line_items.count).to eql(vend_items.count)
    end

    it "adds correct quantity for each item" do
      vend_qty = vend_items.inject(0) { |q, i| q + i.quantity }
      expect(order.item_count).to eql(vend_qty)
    end

    it "adds correct price for each item" do
      vend_item_total = vend_items.inject(0.to_f) { |t, i| t + i.price.to_f * i.quantity.to_i }
      order.update!
      expect(order.item_total.to_f).to eql(vend_item_total)
    end

  end

  describe "#receive_vend_coupons" do

    before(:all) do
      @promotion = Fabricate(:promotion)
    end

    let(:promotion) { @promotion }
    let(:vend_items) { VendObjects.coupon_line_item }

    subject(:order) do
      Order.create.tap do |o|
        o.vend_items = vend_items
        o.send(:receive_vend_coupons)
      end
    end

    it "applies correct adjustment amount" do
      expect(order.adjustments.first.amount.to_f).to eql(vend_items.first.price.to_f)
    end

    it "attributes adjustment to promotion" do
      expect(order.adjustments.first.originator.promotion.code).to eql(vend_items.first.sku)
    end

    it "ignores promotion rules" do
      expect(promotion.eligible?(order)).to be_false
      expect(order.adjustments.first.eligible).to be_true
    end

    it "locks adjustment from future recalculations" do
      expect(order.adjustments.first.locked).to be_true
    end

  end

  describe "#receive_vend_shipping" do

    before(:each) do
      SpreeVend.vend_default_shipping_method_name = "Ground"
      Fabricate(:shipping_method, name: "Ground")
      Fabricate(:shipping_method, name: "Overnight")
    end

    subject(:order) do
      Order.create.tap do |o|
        o.vend_items = vend_items
        o.send(:receive_vend_shipping)
      end
    end

    context "with no default shipping method defined" do
      before { SpreeVend.vend_default_shipping_method_name = nil }
      let(:vend_items) { VendObjects.product_line_items }
      subject(:order) do
        Order.create.tap do |o|
          o.vend_items = vend_items
        end
      end
      
      it "throws an exception" do
        expect { order.send(:receive_vend_shipping)}.to raise_error(VendPosError, "No default shipping method defined for SpreeVend configuration.")
      end

    end

    context "with non-existant default shipping method defined" do
      before { SpreeVend.vend_default_shipping_method_name = "Yesterday Shipping" }
      let(:vend_items) { VendObjects.product_line_items }
      subject(:order) do
        Order.create.tap do |o|
          o.vend_items = vend_items
        end
      end
      
      it "throws an exception" do
        expect { order.send(:receive_vend_shipping)}.to raise_error(VendPosError, "SpreeVend default shipping method is not an available shipping method.")
      end

    end

    context "with no shipping item in vend sale" do
      let(:vend_items) { VendObjects.product_line_items }
      
      it "adds default shipping method to order" do
        expect(order.shipping_method.name).to eql(SpreeVend.vend_default_shipping_method_name)
      end

    end

    context "with a shipping item in vend sale" do
      let(:vend_items) { VendObjects.shipping_line_item }

      it "adds desired shipping method to order" do
        expect(order.shipping_method.name).to eql(vend_items.first.name)
      end

    end

    context "with multiple shipping items in vend sale" do
      let(:vend_items) { VendObjects.shipping_line_items }

      it "behaves unexpectedly" do
        expect(order.shipping_method.name).to satisfy { |n| vend_items.find(n) }
      end

    end

  end

  describe "#receive_vend_adjustments" do

    before(:all) do
      SpreeVend.vend_default_shipping_method_name = "Ground"
      Fabricate(:shipping_method, name: "Ground")
      Fabricate(:shipping_method, name: "Overnight")
      Fabricate(:promotion)
    end

    let(:vend_items) { VendObjects.assortment_of_all_types_of_line_items }

    subject(:order) do
      Order.create.tap do |o|
        o.vend_items = vend_items
        o.send(:receive_vend_items)
        o.send(:receive_vend_coupons)
        o.send(:receive_vend_shipping)
        o.send(:receive_vend_adjustments)
      end
    end

    it "adds line items in vend sale that are not found as variants, coupons, or shipping methods as adjustments" do
      expect(order.adjustments.last.label).to eql(vend_items.last.name)
    end

    it "consolidates adjustment line items with quantites greater than one into a single adjustment" do
      expect(order.adjustments.last.amount).to eql(vend_items.last.quantity.to_i * vend_items.last.price.to_f)
    end

  end

  describe "#receive_vend_tax" do
    it "should be refactored"

    let(:vend_sale) do
      sale = VendObjects.register_sale
      sale.register_sale_products << VendObjects.tax_adjustment_item
      sale.register_sale_products.flatten!
      sale
    end

    subject(:order) do
      Order.create.tap do |o|
        o.vend_sale = vend_sale
        o.send(:receive_vend_tax)
      end
    end

    it "adds vend-applied tax" do
      expect(order.adjustments.tax.map(&:amount)).to include(vend_sale.taxes.first.tax)
    end

    it "adds user-applied tax" do
      expect(order.adjustments.tax.map(&:amount).map(&:to_f)).to include(vend_sale.register_sale_products.find { |i| i.name =~ /tax/i }.price.to_f)
    end

  end

  describe "#receive_vend_payments" do

    before(:all) do
      Fabricate(:vend_payment_method)
    end

    let(:vend_items) { VendObjects.product_line_items }
    let(:vend_payments) { VendObjects.payments }

    subject(:order) do
      Order.create.tap do |o|
        o.vend_payments = vend_payments
        o.vend_items = vend_items
        o.send(:receive_vend_items)
        o.send(:receive_vend_payments)
      end
    end

    it "adds each payment to order" do
      expect(order.payments.count).to eql(vend_payments.count)
    end

    it "adds payments for the right amounts" do
      expect(order.payments.map(&:amount).map(&:to_f)).to match_array(vend_payments.map(&:amount).map(&:to_f))
    end

    it "adds payments as Vend payment methods" do
      expect(order.payments.select { |p| p.payment_method.name == "Vend" }.count).to eql(vend_payments.count)
    end

    context "with processing failure" do
      before { order.stub(:process_payments!).and_raise(StandardError) }

      it "should catch error and fire notification of error" do
        expect(SpreeVend::Notification).to receive(:error)
        order.send(:receive_vend_payments)
      end
    end

  end

end
