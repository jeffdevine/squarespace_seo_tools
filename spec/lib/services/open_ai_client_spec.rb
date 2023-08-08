require "spec_helper"
require_relative "../../../lib/services/open_ai_client"

RSpec.describe(OpenAIClient) do
  let(:content) { {"content" => "Why did the tomato turn red? Because it saw the salad dressing!"} }
  let(:message) { {"message" => content} }
  let(:response) { {"choices" => [message]} }
  let(:mock_client) { instance_double(OpenAI::Client, chat: response) }
  let(:mock_logger) { instance_double(TTY::Logger, debug: true, error: true, fatal: true) }

  describe("#call") do
    it "returns a success monad" do
      allow(OpenAI::Client).to receive(:new).and_return(mock_client)

      response = described_class.call(message: "tell a joke")

      expect(response.success?).to be(true)
    end

    it "returns a response based on provided string" do
      allow(OpenAI::Client).to receive(:new).and_return(mock_client)

      response = described_class.call(message: "tell a joke")

      expect(response.value!).to include("Why did the tomato turn red?")
    end

    it "logs the response from OpenAI when DEBUG is set" do
      allow(OpenAI::Client).to receive(:new).and_return(mock_client)
      allow(TTY::Logger).to receive(:new).and_return(mock_logger)

      described_class.call(message: "tell a joke")

      expect(mock_logger).to have_received(:debug).with(response)
    end

    context("when OpenAI::Client raises an error") do
      it "returns a failure monad" do
        allow(OpenAI::Client).to receive(:new).and_raise(StandardError)

        response = described_class.call(message: "tell a joke")

        expect(response.success?).to be(false)
      end

      it "logs an error message" do
        allow(OpenAI::Client).to receive(:new).and_raise(StandardError)
        allow(TTY::Logger).to receive(:new).and_return(mock_logger)

        described_class.call(message: "tell a joke")

        expect(mock_logger).to have_received(:error).with("[OpenAIClient] - StandardError")
      end
    end

    context("when the requirement is not provided") do
      it "returns a failure monad" do
        response = described_class.call(message: false)

        expect(response.success?).to be(false)
      end

      it "logs an error message" do
        allow(TTY::Logger).to receive(:new).and_return(mock_logger)

        described_class.call(message: false)

        expect(mock_logger).to have_received(:fatal).with("false violates constraints (type?(String, false) failed)")
      end
    end
  end
end
