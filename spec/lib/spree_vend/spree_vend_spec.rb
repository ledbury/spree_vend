require "spec_helper"

describe SpreeVend do

  describe ".parse_json_response" do
    let(:json) { "{ \"r\": \"red\", \"g\": \"green\", \"b\": \"blue\" }" }
    subject(:spree_vend) { SpreeVend }

    it "converts a raw string of JSON into a Hashie::Mash object" do
      expect(SpreeVend).to receive(:parse_json_response).and_return(an_instance_of(Hashie::Mash))
      spree_vend.parse_json_response(json)
    end

    it "returns Mash values that are correct" do
      mash = spree_vend.parse_json_response(json)
      JSON.parse(json).each do |k, v|
        expect(mash.send(k)).to eql(v)
      end
    end
  end

  describe ".vend_cache_key" do
    let(:sale_id) { "some-sale-id" }
    subject(:spree_vend) { SpreeVend }

    it "creates a string for use as a cache key for an individual vend sale" do
      expect(spree_vend.vend_cache_key(sale_id)).to eql("vend_sale:#{sale_id}")
    end
  end

  describe ".generate_csv" do
    subject(:spree_vend) { SpreeVend }

    context "when the argument is valid" do
      let(:rows) { [["A1", "B1"], ["A2", "B2"]] }

      it "returns a csv-formatted string" do
        expect(spree_vend.generate_csv(rows)).to eql("\"A1\",\"B1\"\n\"A2\",\"B2\"\n")
      end
    end
    
    context "when the argument is not valid" do
      let(:rows) { ["A1", "B1", "A2", "B2"] }

      it "raises a TypeError" do
        expect { spree_vend.generate_csv(rows) }.to raise_error(TypeError)
      end
    end
  end

  describe ".customer_export_csv" do
    subject(:spree_vend) { SpreeVend }

    before(:each) { Fabricate.times(3, :user) }

    context "with a scope" do
      before(:all) do
        User.define_singleton_method(:fancy_scope) { where(email: "*") }
      end
      it "uses the defined scope to create the csv" do
        expect(User).to receive(:send).with(:fancy_scope)
        spree_vend.customer_export_csv(:fancy_scope)
      end
      it "returns a csv-formatted string"
    end

    context "with a block" do
      it "filters the users using the passed block"
      it "returns a csv-formatted string"
    end

    context "with no scope or block" do
      it "uses the default scope and no filter on the User model"
      it "returns a csv-formatted string"
    end
  end

  describe "product_export_csv"

end
