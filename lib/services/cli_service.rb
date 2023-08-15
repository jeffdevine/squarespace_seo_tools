require "pastel"
require "tty-prompt"
require "tty-spinner"
require_relative "service"

class CLIService < Service
  private

  def prompt
    @prompt ||= TTY::Prompt.new
  end
end
