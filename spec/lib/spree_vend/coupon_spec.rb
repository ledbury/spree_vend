require "spec_helper"

describe SpreeVend::Coupon do

  let(:promotion) { Fabricate(:promotion) }

  describe ".new" do

    subject(:coupon) { SpreeVend::Coupon.new(promotion) }

    it "sets attribute spree_promotion to an instance of Promotion" do
      expect(coupon.spree_promotion).to eql(promotion)
    end

    it "sets attribute code to the Promotion's code" do
      expect(coupon.code).to eql(promotion.code)
    end

    it "sets attribute name to the Promotion's name" do
      expect(coupon.name).to eql(promotion.name)
    end
  end

  describe "#update" do

    let(:active) { 1 }
    let(:coupon_json) do
      { :sku => promotion.code,
        :handle => promotion.code,
        :type => "Coupon",
        :active => active }.to_json
    end

    subject(:coupon) { SpreeVend::Coupon.new(promotion) }

    before(:each) do
      coupon.spree_promotion.stub(:expired?).and_return(false)
      coupon.spree_promotion.stub(:preferred_usage_limit).and_return(100)
      coupon.spree_promotion.stub_chain(:credits, :count).and_return(1)
    end
    after(:each) { coupon.update }

    context "spree promotion is expired" do

      let(:active) { 0 }

      before(:each) do
        coupon.spree_promotion.stub(:expired?).and_return(true)
      end

      it "updates coupon in vend to be inactive" do
        expect(SpreeVend::Vend).to receive(:post_request).with(SpreeVend::Coupon::RESOURCE_NAME, coupon_json)
      end
    end

    context "spree promotion has been used to its limit" do

      let(:active) { 0 }

      before(:each) do
        coupon.spree_promotion.stub_chain(:credits, :count).and_return(100)
      end

      it "updates coupon in vend to be inactive" do
        expect(SpreeVend::Vend).to receive(:post_request).with(SpreeVend::Coupon::RESOURCE_NAME, coupon_json)
      end
    end

    context "spree promotion is active" do

      let(:active) { 1 }

      it "updates coupon in vend to be inactive" do
        expect(SpreeVend::Vend).to receive(:post_request).with(SpreeVend::Coupon::RESOURCE_NAME, coupon_json)
      end
    end
  end

end
