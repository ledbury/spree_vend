require "spec_helper"

describe Variant do

  let(:vend_product) { double(SpreeVend::Product) }

  subject(:variant) do
    Fabricate(:variant)
  end

  before(:each) do
    SpreeVend::Product.stub(:new).with(variant).and_return(vend_product)
    vend_product.stub(:update)
  end

  describe "#update_vend_inventory" do

    after(:each) { variant.update_vend_inventory }

    context "when it is successful" do
      it "updates vend product's inventory" do
        expect(SpreeVend::Product).to receive(:new).with(variant)
        expect(vend_product).to receive(:update)
      end

      it "logs its success" do
        expect(SpreeVend::Logger).to receive(:info).with(an_instance_of(String))
      end

      it "returns true" do
        expect(variant).to receive(:update_vend_inventory).and_return(true)
      end
    end

    context "when it errors" do
      before(:each) { SpreeVend::Product.stub(:new).with(variant).and_raise(StandardError) }

      it "fires error notification" do
        expect(SpreeVend::Notification).to receive(:error).with(an_instance_of(StandardError), an_instance_of(String))
      end

      it "returns true" do
        expect(variant).to receive(:update_vend_inventory).and_return(true)
      end
    end

  end

end
