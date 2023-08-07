#!/usr/bin/env ruby

require "nokogiri"
require "pastel"
require "tty-prompt"
require "tty-spinner"
require "json"
require_relative "open_ai_client"
require "pry-byebug"

def open_ai_client
  @open_ai_client ||= OpenAIClient.new
end

def build_model_from_html(html_file)
  document = File.open(html_file) { |file| Nokogiri::HTML(file) }

  {
    body: document.xpath("//h1//text() | //h2//text() | //p//text()").map(&:text).join(" "),
    description: document.at('meta[name="description"]'),
    headline: document.at_css("h1").text.strip,
    title: document.title
  }
end

def html_files
  @html_file ||= Dir.glob(File.join("posts", "*.html"))
end

def send_text_to_open_ai(text, prompt)
  spinner.auto_spin
  open_ai_client.call("#{prompt} <#{text}>")
  spinner.success("Done!")
end

def process_html(html_file)
  prompt.say("Processing #{html_file}...")
  seo_data = build_model_from_html(html_file)

  titles = send_text_to_open_ai(seo_data[:body], "Write five actionable blog titles and five clickbait titles based on the text delimited by <>. Return your results as a json array with the key titles.")

  keywords = send_text_to_open_ai(seo_data[:body], "Generate 5 keywords based on the text delimited by <>. Return your results as a json with the key keywords.")

  binding.pry

  descriptions = JSON.parse(keywords).fetch("keywords").map do |keyword|
    send_text_to_open_ai(seo_data[:body], "Write a meta description of a maximum of 150 characters based on the text delimited by <> and use the keyword #{keyword} in the meta description.")
  end

  seo_data_json = {
    descriptions: descriptions,
    keywords: JSON.parse(keywords).fetch("keywords"),
    title: seo_data.fetch(:title),
    titles: JSON.parse(titles).fetch("titles"),
    url: "https://www.malinamalkani.com.com/blog/#{html_file}"
  }

  write_html_changes_to_disk(html_file, seo_data_json)

  prompt.say(" [✔] Processed #{html_file}")
end

def prompt
  @prompt ||= TTY::Prompt.new
end

def spinner
  @spinner ||= TTY::Spinner.new(" [:spinner] Calling OpenAI API...", format: :classic, success_mark: Pastel.new.green("✔"))
end

def write_html_changes_to_disk(filename, data)
  Dir.mkdir("seo") unless Dir.exist?("seo")
  File.write(filename.gsub(".html", ".json").gsub("posts/", "seo/"), JSON.pretty_generate(data))
end

html_files.each do |html_file|
  process_html(html_file)
end

prompt.say("✔ Done!", color: :green)
