require "spec_helper"
require_relative "../../../lib/services/json_transformer"

RSpec.describe(JSONTransformer) do
  let(:html_file_name) { "post_1.html" }
  let(:json_file_path) { "#{File.expand_path("../../..", __dir__)}/json-ld/post_1.json" }
  let(:mock_file) { instance_double(File, write: true) }
  let(:mock_spinner) { instance_double(TTY::Spinner, run: true) }

  describe("#call") do
    it "returns a success monad" do
      response = described_class.call(html_path: "html")

      expect(response.success?).to be(true)
    end

    it "writes JSON-LD files to output_path" do
      allow(Dir).to receive(:glob).and_return([html_file_name])
      allow(File).to receive(:write).and_return(mock_file)
      allow(File).to receive(:open).and_return(blog_post)

      described_class.call(html_path: "html")

      expect(File).to have_received(:write).with(json_file_path, json_result)
    end
  end

  def blog_post
    @html ||= Nokogiri::HTML(File.read("spec/fixtures/post_1.html"))
  end

  def json_result
    @json_result ||= File.read("spec/fixtures/post_1.json").chomp
  end
end
