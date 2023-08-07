#!/usr/bin/env ruby

require "nokogiri"
require "open-uri"
require "pastel"
require "tty-prompt"
require "tty-spinner"

def prompt
  @prompt ||= TTY::Prompt.new
end

def blog_posts_for(url)
  sitemap_doc = Nokogiri::XML(URI.parse("#{url}/sitemap.xml").open)
  site_urls = sitemap_doc.css("loc").map { |node| node.text }
  site_urls.select { |node| node.include?("/blog/") }
end

def save_post_to_disk(post_url)
  Dir.mkdir("posts") unless Dir.exist?("posts")
  post_html = Nokogiri::HTML(URI.parse(post_url).open)
  File.write("posts/#{post_url.split("/").last}.html", post_html.to_html)
end

def scrape_website
  prompt.say("Scraping #{website}...", color: :green)
  posts = blog_posts_for(website)

  posts.each_with_index do |post_url, counter|
    prompt.say("- Fetching [#{counter + 1}/#{posts.count}] #{post_url}...")

    save_post_to_disk(post_url)

    take_a_break_for(rand(45..119).to_i)
  end

  prompt.say("✔ Done!", color: :green)
end

def sitemap_for(url)
  Nokogiri::XML(URI.parse("#{url}/sitemap.xml").open)
end

def site_urls_for(url)
  sitemap_for(url).css("loc").map { |node| node.text }
end

def spinner
  @spinner ||= TTY::Spinner.new("  [:spinner] :title", format: :classic, success_mark: Pastel.new.green("✔"))
end

def take_a_break_for(interval)
  spinner.run do |spin|
    interval.times.each do |i|
      spin.update(title: "Taking a #{interval - i} second break...")
      sleep(1)
    end
    spin.success
  end
end

def website
  @website ||= prompt.ask("Enter the website to scrape?", default: "https://jeffdevine.com") do |input|
    input.required true
    input.validate(/\A#{URI::DEFAULT_PARSER.make_regexp(['http', 'https'])}\z/)
    input.modify :trim
  end
end

scrape_website
