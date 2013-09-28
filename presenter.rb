require_relative "models/story"
require_relative "models/model"

puts Time.now

# this is for conditionally formatting the probabilities
def color_from_prob(p)
  # want 100% to be green 0,255,0
  # want 0% to be red 255,0,0
  rgb = [255 * (1-p),255 * p, 0]
  hex = rgb.map{|i| sprintf("%02x", i).upcase}.join
  return hex
end

new_stories = Story.where(:tweeted => nil).sort(:hnid.desc).take(10)

puts "found #{new_stories.size} new stories"

model = Model.load

# now need to order by probability descending
probs = new_stories.map{ |s| model.classify(s,true) }
sorted_stories = probs.zip(new_stories).sort{ |s1,s2| s2.first <=> s1.first }

begin
  if sorted_stories.size > 0
    puts "Hacker News stories for #{Time.now.strftime("%l %p on %A %b %d, %Y").strip}"
    puts

    sorted_stories.map do |prob,s|
      #color = color_from_prob prob
      title = s.link_title #s.link_title.gsub("&","&amp;").gsub("<","&lt;").gsub(">","&gt;")
      hn_link = "http://news.ycombinator.com/item?id=#{s.hnid}"
      link = /^http/ =~ s.link_url ? s.link_url : hn_link

      puts %Q[**#{sprintf("%.3f",prob)}** [#{title}](#{link}) [*comments*](#{hn_link})\n]
    end

    new_stories.each do |s|
      s.tweeted = true
      s.tweeted_at = Time.now
      s.save
    end
  else
    puts "No new stories"
  end
rescue Exception => e
  puts e.inspect
end
