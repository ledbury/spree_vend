require "spec_helper"

describe Order do

  describe "#load_vend_sale_object"

  describe "#receive_vend_customer" do

    before do
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

    before { Fabricate.times(3, :variant) }

    let(:vend_items) { VendObjects.line_items }

    subject(:order) do
      Order.create.tap do |o|
        o.vend_items = vend_items
        o.send(:receive_vend_items)
      end
    end

    it "adds each item to order"

    it "adds correct quantity for each item"

    it "adds correct price for each item"

    it "does not combine same items with different prices"

  end

  describe "#receive_vend_coupons"

  describe "#receive_vend_shipping"

  describe "#receive_vend_adjustments"

  describe "#receive_vend_tax"

  describe "#receive_vend_payments"

end
