require "link_thumbnailer"

LinkThumbnailer.configure do |config|
  # Whether you want to validate given website against mandatory attributes or not.
  config.strict = false

  # Numbers of redirects before raising an exception when trying to parse given url.
  config.redirect_limit = 3

  # Fetch 2 images maximum.
  config.limit = 2

  # Return top image only.
  config.top = 1

  # Set user agent
  config.user_agent = "hacker-news-filter"

  # HTTP open_timeout: The amount of time in seconds to wait for a connection to be opened.
  config.http_timeout = 5
end
