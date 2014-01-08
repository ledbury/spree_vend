require "spec_helper"

describe ShippingMethod do

  let(:vend_shipping_method) { double(SpreeVend::ShippingMethod) }

  subject(:shipping_method) do
    Fabricate(:shipping_method)
  end

  before(:each) do
    SpreeVend::ShippingMethod.stub(:new).with(shipping_method).and_return(vend_shipping_method)
    vend_shipping_method.stub(:update)
  end

  describe "#update_vend_shipping_method" do

    after(:each) { shipping_method.update_vend_shipping_method }

    context "when it is successful" do
      it "updates vend shipping method" do
        expect(SpreeVend::ShippingMethod).to receive(:new).with(shipping_method)
        expect(vend_shipping_method).to receive(:update)
      end

      it "logs its success" do
        expect(SpreeVend::Logger).to receive(:info).with(an_instance_of(String))
      end

      it "returns true" do
        expect(shipping_method).to receive(:update_vend_shipping_method).and_return(true)
      end
    end

    context "when it errors" do
      before(:each) { SpreeVend::ShippingMethod.stub(:new).with(shipping_method).and_raise(StandardError) }

      it "fires error notification" do
        expect(SpreeVend::Notification).to receive(:error).with(an_instance_of(StandardError), an_instance_of(String))
      end

      it "returns true" do
        expect(shipping_method).to receive(:update_vend_shipping_method).and_return(true)
      end
    end

  end

end
