require_relative "cli_service"
require "nokogiri"
require "nori"
require "net/http"
require "pry-byebug"

class SiteMapper < CLIService
  option :url, type: Dry::Types["strict.string"]
  option :path, optional: true, type: Dry::Types["strict.string"]
  option :last_modification, optional: true, type: Dry::Types["strict.date"]

  def call
    Success.new(load_sitemap_and_parse)
  rescue => e
    log_with_failure(e.message)
  end

  private

  def clean_sitemap
    sitemap_as_hash.reject { |node| node["lastmod"].nil? }
  end

  def limit_sitemap_by_path(pages)
    pages = pages.select { |node| node["loc"].include?("/#{path}/") } if path
    pages
  end

  def limit_sitemap_by_last_modification_date(pages)
    pages = pages.select { |node| node["lastmod"] >= last_modification } if last_modification
    pages
  end

  def load_sitemap_and_parse
    pages = limit_sitemap_by_path(clean_sitemap)
    pages = limit_sitemap_by_last_modification_date(pages)
    pages.map { |node| node["loc"] }
  end

  def sitemap
    @sitemap ||= Net::HTTP.get(URI.parse("#{url}/sitemap.xml"))
  end

  def sitemap_as_hash
    @sitemap_as_hash ||= Nori.new.parse(Nokogiri::XML(sitemap).to_s)["urlset"]["url"]
  end
end
