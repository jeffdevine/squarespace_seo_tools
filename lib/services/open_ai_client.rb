require "openai"
require_relative "service"

class OpenAIClient < Service
  option :message, type: Dry::Types["strict.string"]

  def call
    Success.new(send_message_and_parse_response)
  rescue => e
    log_with_failure(e.message)
  end

  private

  def client
    @client ||= OpenAI::Client.new(access_token: openai_api_key)
  end

  def messages
    [{role: "user", content: @message}]
  end

  def model
    @model ||= ENV.fetch("OPENAI_MODEL", "gpt-3.5-turbo")
  end

  def openai_api_key
    @openai_api_key ||= ENV.fetch("OPENAI_API_KEY", "api_key")
  end

  def parameters
    {
      messages:, model:, temperature:
    }
  end

  def parse_response(response)
    logger.debug(response)
    response.dig("choices", 0, "message", "content")
  end

  def send_message_and_parse_response
    response = client.chat(parameters:)
    parse_response(response)
  end

  def temperature
    @temperature ||= ENV.fetch("OPENAI_TEMPERATURE", 0.7)
  end
end
