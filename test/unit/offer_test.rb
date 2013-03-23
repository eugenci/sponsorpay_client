#encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class OfferTest < ActiveSupport::TestCase

  context "Offer model is instanciated ok" do
    setup do
      stub_request(:get, %r{.*sponsorpay.*}).
        to_return(body: body_with_2_offers, :status => 200)
    end

    should "return two Offer objects" do
      o = Offer.find(:all,:params => Offer.prepare_params)
      assert o.present?
      assert o.first.is_a?(Offer)
      assert_equal 'title1', o.first.title
      assert_equal '1', o.first.payout
      assert_equal 'title2', o.last.title
      assert_equal '2', o.last.payout
    end
  end

  context "Prepare request" do
    should "sort input params and convert to params" do
      params = {'device_id' =>  178, 'ip' => '127.0.0.1', 'api_key' => 'abc', 'appid' => 1}
      assert_equal 'api_key=abc&appid=1&device_id=178&ip=127.0.0.1',Offer.hash_to_sorted_str(params)
    end

    should "provice correct hash key" do
      params = {'device_id' =>  178, 'ip' => '127.0.0.1', 'api_key' => 'abc'}
      ApiConfig.stubs(:api_key).returns('xxxyyy')
      str = 'api_key=abc&device_id=178&ip=127.0.0.1&xxxyyy'
      hk = Digest::SHA1.hexdigest(str)
      assert_equal hk, Offer.hashkey(params)
    end
  end
end
