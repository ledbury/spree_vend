require "spec_helper"

describe SpreeVend::Vend do

  before(:each) do
    SpreeVend.setup do |c|
      c.vend_store_name = Faker::Company.name.parameterize
      c.vend_username = Faker::Internet.email
      c.vend_password = Faker::Internet.user_name
      c.vend_outlet_name = Faker::HipsterIpsum.word.parameterize
    end
  end

  describe "#set_credentials" do
    its(:store_name) { should eql(SpreeVend.vend_store_name) }
    its(:username) { should eql(SpreeVend.vend_username) }
    its(:password) { should eql(SpreeVend.vend_password) }
    its(:outlet_name) { should eql(SpreeVend.vend_outlet_name) }
  end

  describe ".post_request" do
    it "logs sending of request" do
      Curl::Easy.any_instance.stub(:perform)
      expect(SpreeVend::Logger).to receive(:info)
      expect { |b| Curl.post("url", &b) }.to yield_with_args
      SpreeVend::Vend.post_request("test", "test")
    end
  end

  describe ".get_request" do
    it "logs sending of request" do
      Curl::Easy.any_instance.stub(:perform)
      expect(SpreeVend::Logger).to receive(:info)
      expect { |b| Curl.get("url", &b) }.to yield_with_args
      SpreeVend::Vend.get_request("test")
    end
  end

end
