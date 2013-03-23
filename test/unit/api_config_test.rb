#encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ApiConfigTest < ActiveSupport::TestCase
  context "Accessing Configuration from config/api_config.yml" do
    setup do
      @conf = ApiConfig.new
    end

    should "be able to get api_key" do
      assert @conf.api_key.present?
    end

    should "be able to get appid" do
      assert @conf.appid.present?
    end

    should "be able to get config params as class methods" do
      assert ApiConfig.fmt.present?
      assert ApiConfig.base_url.present?
    end
  end
end
