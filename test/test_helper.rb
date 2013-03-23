ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/test_unit'

class ActiveSupport::TestCase
  def body_with_2_offers
    '{"code":"OK", "offers": [{"title":"title1","payout":"1","thumbnail":{"lowres":"http://x.com"}},{"title":"title2","payout":"2","thumbnail":{"lowres":"http://y.com"}}]}'
  end

  def body_with_no_offers
    '{"code":"OK", "offers": []}'
  end
end
