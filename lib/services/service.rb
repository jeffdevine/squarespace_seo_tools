require "dry-initializer"
require "dry-validation"
require "dry/core"
require "dry/monads"
require "dry/types"
require "tty-logger"

class Service
  extend Dry::Initializer
  include Dry::Monads::Result::Mixin
  extend Dry::Core::ClassAttributes

  def self.call(**args)
    new(**args).call
  rescue => e
    handle_fatal_error(e)
  end

  def self.handle_fatal_error(error)
    TTY::Logger.new.fatal(error.message)
    Failure.new(error.message)
  end

  def log_with_failure(message)
    logger.error("[#{self.class.name}] - #{message}")
    Failure.new(message)
  end

  private

  def logger
    @logger ||= TTY::Logger.new do |config|
      config.level = ENV.fetch("DEBUG", false) ? :debug : :error
    end
  end
end
