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
      include_context "an anonymous user"
      include_examples "receives a vend customer"

      it "creates anonymous user" do
        expect(order.user.anonymous?).to be_true
      end
    end

    context "with a bad address" do
      include_context "a user with an invalid address"
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
      include_context "a user with all required info"
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
    end

    subject(:order) do
      Order.create.tap do |o|
        o.vend_items = vend_items
        o.send(:receive_vend_items)
      end
    end

    let(:vend_items) do
      Hashie::Mash.new([
        {
          quantity: 1,
          price: "50.0",
          sku: "sku-1",
        },
        {
          quantity: 2,
          price: "51.0",
          sku: "sku-2",
        },
        {
          quantity: 1,
          price: "10.0",
          sku: "sku-3",
        },
        {
          quantity: 1,
          price: "20.0",
          sku: "sku-3",
        }
      ])
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
