# manually score stories as like or dislike, for use in building the model
# "ruby judger.rb" to see unjudged stories

require_relative "models/story"
require_relative "models/model"
require_relative "utils/utils"

# unjudged stories, sorted by hnid descending
total = Story.count
stories = Story.where(:like => nil).sort(:hnid.desc)
unjudged_count = stories.count

puts "#{total} stories in database"
puts "#{total - unjudged_count} judged"
puts "#{unjudged_count} left to judge"
puts

stories.each do |s|
  puts "hnid: #{s.hnid}"
  puts "title: #{s.link_title}"

  if s.summary
    puts "summary: #{s.summary[0, 180]}"
  end

  puts "domain: #{s.domain}"
  puts "url: #{s.link_url}"
  puts "user: #{s.user}"
  puts
  puts "previous judgment: #{s.like}" if s.like
  puts "prediction: #{s.prediction}" if s.prediction
  print "good? >> "
  answer = STDIN.gets
  if /^y/i =~ answer
    puts "you liked it!"
    s.like = true
  elsif /^n/i =~ answer
    puts "you didn't like it!"
    s.like = false
  else break
  end

  s.save
  puts
end

puts "retraining model"
# after judging, retrain the model
model = Model.new
model.train(2)
model.save

# and reclassify everything

require_relative "utils/back_predict"
back_predict(false,false)

require_relative "utils/test_featurizer"
