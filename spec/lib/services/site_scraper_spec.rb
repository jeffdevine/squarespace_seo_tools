require "spec_helper"
require_relative "../../../lib/services/site_scraper"

RSpec.describe(SiteScraper) do
  let(:site) { "https://example.com/" }
  let(:first_post) { "#{site}blog/post_1" }
  let(:sitemap) { Dry::Monads::Result::Mixin::Success.new([first_post]) }
  let(:today) { Date.today }
  let(:mock_spinner) { instance_double(TTY::Spinner, run: true) }

  describe("#call") do
    it "returns a success monad" do
      stub_network_calls

      allow(TTY::Spinner).to receive(:new).and_return(mock_spinner)

      response = described_class.call(site: site)

      expect(response.success?).to be(true)
    end

    it "returns saves posts for a specific path" do
      stub_network_calls

      described_class.call(site: site, path: "blog")

      expect(Sitemapper).to have_received(:call).with(
        last_modification: nil, path: "blog", url: site
      )
    end

    it "returns saves posts for a specific date" do
      stub_network_calls

      described_class.call(site: site, last_modification: today)

      expect(Sitemapper).to have_received(:call).with(
        last_modification: today, path: nil, url: site
      )
    end
  end

  def stub_network_calls
    allow(TTY::Spinner).to receive(:new).and_return(mock_spinner)
    allow(Sitemapper).to receive(:call).and_return(sitemap)
    allow(Net::HTTP).to receive(:get).and_return(html)
  end

  def html
    @html ||= File.open("spec/fixtures/post_1.html")
  end
end
