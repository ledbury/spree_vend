require "spec_helper"

describe SpreeVend::Product do

  let(:variant) { Fabricate(:variant) }

  subject(:product) { SpreeVend::Product.new(variant) }

  describe ".new" do
    specify { expect(product.spree_variant).to eql(variant) }
  end

  describe "#handle" do
    specify { expect(product.handle).to eql(variant.sku) }
  end

  describe "#active?" do
    after(:each) { product.active? }

    it "returns 1 when Variant#active_in_vend? returns true" do
      expect(product).to receive(:active?).and_return(1)
    end

    it "returns 0 when Variant#active_in_vend? returns false" do
      variant.stub(:active_in_vend?).and_return(false)
      expect(product).to receive(:active?).and_return(0)
    end
  end

  describe "#update" do
    before(:each) { SpreeVend::Vend.stub(:post_request).with("products", an_instance_of(String)) }
    after(:each) { product.update }

    let(:variant) { Fabricate(:variant, option_values: Fabricate.times(2, :option_value))}

    it "sends request to Vend to update product" do
      expect(SpreeVend::Vend).to receive(:post_request).with("products", an_instance_of(String))
    end

    it "includes variant option values with update request" do
      expect(SpreeVend::Vend).to receive(:post_request) do |arg1, arg2|
        json = JSON.parse(arg2)
        expect(arg1).to eql("products")
        expect(json[:variant_option_one_name].length).to be > 1
        expect(json[:variant_option_one_value]).to be > 1
        expect(json[:variant_option_two_name]).to be > 1
        expect(json[:variant_option_two_value]).to be > 1
      end
    end
  end

end
