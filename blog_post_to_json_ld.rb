#!/usr/bin/env ruby

require "nokogiri"
require "pastel"
require "tty-prompt"
require "tty-spinner"
require "json"
require_relative "open_ai_client"

FAQ_SCHEMA = {"@context": "https://schema.org", "@type": "FAQPage"}

def build_faq_structure(faq)
  {
    "@type": "Question",
    name: faq.text.strip,
    acceptedAnswer: {
      "@type": "Answer",
      text: make_readable(faq.next_element.text.strip)
    }
  }
end

def open_ai_client
  @open_ai_client ||= OpenAIClient.new
end

def extract_faqs_from_html(html_file)
  document = File.open(html_file) { |file| Nokogiri::HTML(file) }

  document.css("h2").map do |faq|
    build_faq_structure(faq) if faq.next_element
  end
end

def html_files
  @html_file ||= Dir.glob(File.join("posts", "*.html"))
end

def make_readable(text)
  spinner.auto_spin
  readable_text = open_ai_client.call("Simplify the following text: #{text}")
  spinner.success("Done!")
  prompt.say(" - Old: #{text}", color: :red)
  prompt.say(" - New: #{readable_text}", color: :green)
  readable_text
end

def process_html_to_ld_json(html_file)
  faqs = extract_faqs_from_html(html_file)

  write_json_ld_to_file(html_file, FAQ_SCHEMA.merge(mainEntity: faqs)) unless faqs.empty?

  prompt.say(" [✔] Processed #{html_file}")
end

def prompt
  @prompt ||= TTY::Prompt.new
end

def spinner
  @spinner ||= TTY::Spinner.new(" [:spinner] Calling OpenAI API...", format: :classic, success_mark: Pastel.new.green("✔"))
end

def write_json_ld_to_file(filename, json_ld)
  Dir.mkdir("json-ld") unless Dir.exist?("json-ld")
  File.write(filename.gsub(".html", ".json").gsub("posts/", "json-ld/"), JSON.pretty_generate(json_ld))
end

html_files.each do |html_file|
  process_html_to_ld_json(html_file)
end

prompt.say("✔ Done!", color: :green)
