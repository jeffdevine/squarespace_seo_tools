require_relative "site_mapper"

class SiteScraper < CLIService
  option :site, type: Dry::Types["strict.string"]
  option :path, optional: true, type: Dry::Types["strict.string"]
  option :last_modification, optional: true, type: Dry::Types["strict.date"]

  DEFAULT_DATE = Date.today.prev_year(20)

  def call
    Success.new(scrape_site)
  rescue => e
    log_with_failure(e.message)
  end

  private

  def pages
    @pages ||= SiteMapper.call(url: site, path: path, last_modification: last_modification || DEFAULT_DATE).value_or([])
  end

  def scrape_site
    prompt.say("Scraping #{site}...", color: :green)
    scrape
    prompt.say("✔ Done!", color: :green)
  end

  def scrape
    pages.each_with_index do |post_url, counter|
      prompt.say("- Fetching [#{counter + 1}/#{pages.count}] #{post_url}...")

      save_to_disk(
        "#{post_url.split("/").last}.html",
        Nokogiri::HTML(fetch_url(post_url)).to_html,
        "posts"
      )

      take_a_break_for(rand(@sleep_range).to_i)
    end
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
end
