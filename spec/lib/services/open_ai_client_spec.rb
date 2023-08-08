require "spec_helper"
require_relative "../../../lib/services/open_ai_client"

RSpec.describe(OpenAIClient) do
  let(:content) { {"content" => "Why did the tomato turn red? Because it saw the salad dressing!"} }
  let(:message) { {"message" => content} }
  let(:response) { {"choices" => [message]} }
  let(:mock_client) { instance_double(OpenAI::Client, chat: response) }

  describe("#call") do
    it "returns a response based on provided string" do
      allow(OpenAI::Client).to receive(:new).and_return(mock_client)

      response = described_class.new.call(message: "tell a joke")

      expect(response).to include("Why did the tomato turn red?")
    end
  end
end
