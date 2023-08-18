require "pastel"
require "tty-prompt"
require "tty-spinner"
require_relative "service"

class CLIService < Service
  private

  def fetch_url(url)
    Net::HTTP.get(URI.parse(url))
  end

  def prompt
    @prompt ||= TTY::Prompt.new
  end

  def save_to_disk(filename, content, path)
    Dir.mkdir("path") unless Dir.exist?("path")
    File.write("#{path}/#{filename}", content)
  end

  def spinner
    @spinner ||= TTY::Spinner.new("  [:spinner] :title", format: :classic, success_mark: Pastel.new.green("✔"))
  end
end
