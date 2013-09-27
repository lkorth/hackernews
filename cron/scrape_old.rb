# scrapes the archives of hn daily to get old data for training

require "nokogiri"
require "open-uri"
require_relative "../config/link_thumbnailer_config"
require_relative "../models/story"
require_relative "../utils/utils"

root_url = "http://www.daemonology.net/hn-daily" #2012-01.html"

def last_two_months_archive_pages(root_url)
  doc = Nokogiri::HTML(open(root_url))
  doc.xpath("//div[@class='marginlink']/a").to_a
            .map { |node| node["href"] }
            .select { |url| url =~ /[0-9]{4}\-[0-9]{2}\.html/ }
            .map { |url| "#{root_url}/#{url}" }
            .first(2)
end


def scrape_month_page(url)
  doc = Nokogiri::HTML(open(url))

  storylinks = doc.xpath("//li/span[@class='storylink']/a")
  commentlinks = doc.xpath("//li/span[@class='commentlink']/a")

  if storylinks.size === commentlinks.size
    (storylinks.zip commentlinks).map do |sl,cl|
      title = sl.text
      url = sl["href"]
      hnurl = cl["href"]

      [url,hnurl,title]
    end
  end
end

def scrape_story(url, hnurl, title)
  summary = ''
  begin
    summary = LinkThumbnailer.generate(url).description
  rescue
  end

  begin
    story = Story.new
    story.link_url = url
    story.domain = domain(url)
    story.hnid = hnid_from_url(hnurl)
    story.link_title = title
    story.summary = summary
    story.scraped_at = Time.now
    story.save

    puts story.link_url
    puts story.domain
    puts story.hnid
    puts story.link_title
    puts story.summary
    puts
  rescue
  end
end

last_two_months_archive_pages(root_url).each do |url|
  puts "scraping month archive"
  scrape_month_page(url).each do |url,hnurl,title|
    scrape_story(url, hnurl, title)
  end
end
