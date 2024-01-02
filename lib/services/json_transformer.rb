require "json"
require "nokogiri"
require_relative "cli_service"
require_relative "open_ai_client"

class JSONTransformer < CLIService
  option :html_path, type: Dry::Types["strict.string"]
  option :reword_answer, optional: true, type: Dry::Types["strict.string"]

  FAQ_SCHEMA = {"@context": "https://schema.org", "@type": "FAQPage"}

  def call
    prompt.say("Processing files in #{@html_path}...")
    Success.new(transform_json)
  rescue => e
    log_with_failure(e.message)
  end

  private

  def build_faq_structure(faq)
    answer = faq.next_element.text.strip
    answer = make_readable(answer) if call_openai?
    {
      "@type": "Question",
      name: faq.text.strip,
      acceptedAnswer: {
        "@type": "Answer",
        text: answer
      }
    }
  end

  def call_openai?
    @reword_answer != Dry::Initializer::UNDEFINED
  end

  def html_files
    @html_file ||= Dir.glob(File.join("#{PROJECT_ROOT}/#{@html_path}/", "*.html"))
  end

  def make_readable(text)
    spinner.auto_spin
    readable_text = OpenAIClient.call(message: "Simplify the following text: #{text}").value!
    spinner.success("Done!")
    prompt.say(" - Old: #{text}", color: :red)
    prompt.say(" - New: #{readable_text}", color: :green)
    readable_text
  end

  def process_html_to_ld_json(html_file)
    save_to_disk(
      rename_html_to_json(html_file),
      transform_html_to_json_faq(html_file),
      "#{PROJECT_ROOT}/json-ld"
    )

    prompt.say(" [#{Pastel.new.green("✔")}] Processed #{html_file}")
  end

  def rename_html_to_json(filename)
    filename.gsub(".html", ".json").gsub("posts/", "json-ld/")
  end

  def transform_json
    html_files.each do |html_file|
      process_html_to_ld_json(html_file)
    end
    prompt.say("✔ Done!", color: :green)
  end

  def transform_html_to_json_faq(html_file)
    document = File.open(html_file) { |file| Nokogiri::HTML(file) }

    faqs = document.css("h2").map do |faq|
      build_faq_structure(faq) if faq.next_element
    end

    JSON.pretty_generate(FAQ_SCHEMA.merge(mainEntity: faqs))
  end
end
