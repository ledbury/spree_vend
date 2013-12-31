require "spec_helper"

describe Order do

  describe "#load_vend_sale_object"

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
      let(:vend_customer) { VendObjects.anonymous_customer }
      include_examples "receives a vend customer"

      it "creates anonymous user" do
        expect(order.user.anonymous?).to be_true
      end
    end

    context "with a bad address" do
      let(:vend_customer) { VendObjects.invalid_address_customer }
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
      let(:vend_customer) { VendObjects.customer }
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

    before do
      Fabricate.times(3, :variant)
      Fabrication::Sequencer.reset
    end

    let(:vend_items) { VendObjects.line_items }

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

    before do
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

    it { expect(ShippingMethod.find_by_name("Ground")).not_to be_nil }

    context "with no default shipping method defined" do
      before { SpreeVend.vend_default_shipping_method_name = nil }
      let(:vend_items) { VendObjects.line_items }
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
      let(:vend_items) { VendObjects.line_items }
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
      let(:vend_items) { VendObjects.line_items }
      
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

  describe "#receive_vend_adjustments"

  describe "#receive_vend_tax"

  describe "#receive_vend_payments"

end
