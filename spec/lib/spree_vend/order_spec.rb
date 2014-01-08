require "spec_helper"

describe SpreeVend::Order do

  let(:register_sale) { VendObjects.register_sale }

  describe ".new" do

    context "without vend order id" do
      specify { expect { SpreeVend::Order.new }.to raise_error(VendPosError) }
    end

    context "with invalid vend order id" do
      before(:each) { SpreeVend::Vend.stub(:get_request).and_return { nil } }

      specify { expect { SpreeVend::Order.new("invalid-vend-order-id") }.to raise_error(VendPosError) }
    end

    context "with present and valid vend order id" do
      before(:each) { SpreeVend::Vend.stub(:get_request).and_return { Hashie::Mash.new(register_sales: [ register_sale ]) } }

      specify { expect(SpreeVend::Order.new("valid-vend-order-id").attributes).to eql(register_sale) }
    end
  end

  describe "#insert_in_spree" do
    let(:spree_order) { double(::Order) }
    let(:adjustment) { double(::Adjustment) }
    let(:vend_coupon) { double(SpreeVend::Coupon) }

    subject(:vend_order) { SpreeVend::Order.new("valid-vend-order-id") }

    before(:each) do
      ::Order.stub(:create).and_return(spree_order)
      spree_order.stub(:populate_with_vend_sale).and_return(true)
      spree_order.stub(:finalize_quietly).and_return(true)
      spree_order.stub_chain(:adjustments, :promotion).and_return([adjustment])
      adjustment.stub_chain(:originator, :promotion).and_return(double(Promotion))
      SpreeVend::Coupon.stub(:new).and_return(vend_coupon)
      vend_coupon.stub(:update)
      SpreeVend::Vend.stub(:get_request).and_return { Hashie::Mash.new(register_sales: [ register_sale ]) }
      vend_order.insert_in_spree
    end

    it "creates new spree order" do
      expect(vend_order.spree_order).to eql(spree_order)
    end

    it "populates spree order with vend sale details" do
      expect(vend_order.spree_order).to have_received(:populate_with_vend_sale).with(vend_order.attributes)
    end

    it "finalizes spree order" do
      expect(vend_order.spree_order).to have_received(:finalize_quietly)
    end

    it "updates any used promos in vend" do
      expect(vend_coupon).to have_received(:update)
    end

  end

end