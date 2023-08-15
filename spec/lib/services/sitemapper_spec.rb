require "spec_helper"
require_relative "../../../lib/services/sitemapper"

RSpec.describe(Sitemapper) do
  let(:url) { "https://example.com/" }
  let(:first_post) { "#{url}blog/post_1" }
  let(:second_post) { "#{url}blog/post_2" }
  let(:urls) { [url, first_post, second_post] }

  describe("#call") do
    it "returns a success monad" do
      allow(Net::HTTP).to receive(:get).and_return(sitemap)

      response = described_class.call(url: "https://example.com")

      expect(response.success?).to be(true)
    end

    it "returns an array of URLs" do
      allow(Net::HTTP).to receive(:get).and_return(sitemap)

      response = described_class.call(url: "https://example.com")

      expect(response.value!).to eql(urls)
    end

    it "returns an array of URLs for a specific path" do
      allow(Net::HTTP).to receive(:get).and_return(sitemap)

      response = described_class.call(url: "https://example.com", path: "blog")

      expect(response.value!).to eql([first_post, second_post])
    end

    it "returns an array of URLs for a specific last modification date" do
      allow(Net::HTTP).to receive(:get).and_return(sitemap)

      last_modification = Date.parse("30/8/2023")

      response = described_class.call(url: "https://example.com", last_modification: last_modification)

      expect(response.value!).to eql([second_post])
    end
  end

  def sitemap
    @sitemap ||= File.open("spec/fixtures/sitemap.xml")
  end
end
