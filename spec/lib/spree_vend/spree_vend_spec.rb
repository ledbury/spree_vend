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
    let(:users) { Fabricate.times(8, :user) }
    subject(:spree_vend) { SpreeVend }

    before(:each) { users }

    context "with a block" do
      let(:block) { Proc.new { |user| user.email =~ /\.com/ } }

      it "filters the users, including users for which the block returns true" do
        expect(spree_vend.customer_export_csv(&block).lines.count - 1).to eql(users.select(&block).count)
      end
      it "returns a csv-formatted string" do
        cols = 11
        rows = users.select(&block).count + 1
        cells = cols * rows
        expect(spree_vend.customer_export_csv).to match(/("[\w\d\s_\.\-\@\(\)']*?",?\n?){#{cells}}/)
      end
    end

    context "with no scope or block" do

      it "uses the default scope and no filter on the User model" do
        expect(spree_vend.customer_export_csv).to include(*User.all.map(&:email))
      end

      it "returns a csv-formatted string" do
        cols = 11
        rows = users.count + 1
        cells = cols * rows
        expect(spree_vend.customer_export_csv).to match(/("[\w\d\s_\.\-\@\(\)']*?",?\n?){#{cells}}/)
      end
    end
  end

  describe ".product_export_csv" do
    let(:variants) { Fabricate.times(8, :variant) }
    subject(:spree_vend) { SpreeVend }

    before(:each) { variants }

    context "with a block" do
      let(:block) { Proc.new { |variant| variant.sku.to_i > 2 } }

      it "filters the users, including users for which the block returns true" do
        expect(spree_vend.product_export_csv(&block).match(/\n/).size - 1).to eql(variants.select(&block).count)
      end
      it "returns a csv-formatted string" do
        cols = 20
        rows = spree_vend.product_export_csv(&block).match(/\n/).size
        cells = cols * rows
        expect(spree_vend.product_export_csv).to match(/("[\w\d\s_\.\-\@\(\)']*?",?\n?){#{cells}}/)
      end
    end

    context "with no scope or block" do

      it "uses the default scope and no filter on the User model" do
        expect(spree_vend.product_export_csv).to include(*Variant.all.map(&:sku))
      end

      it "returns a csv-formatted string" do
        cols = 20
        rows = variants.count + 1
        cells = cols * rows
        expect(spree_vend.product_export_csv).to match(/("[\w\d\s_\.\-\@\(\)']*?",?\n?){#{cells}}/)
      end
    end
  end

end
