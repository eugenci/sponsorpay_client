class Offer < ActiveResource::Base

  VALID_PARAM_KEYS = ApiConfig::CONFIG_PARAM_KEYS + %w(ps_time pub0 page timestamp android_id)

  self.site   = ApiConfig.base_url
  self.format = ApiConfig.fmt.to_sym

  # this method is added by ActiveResource-response gem
  add_response_method :http_response

  def self.prepare_params(params = {})
    pa = params.merge(ApiConfig.base_params).merge('timestamp' => Time.now.to_i)
    hk = hashkey(pa)
    pa.merge('hashkey' => hk)
  end

  def self.hash_to_sorted_str(params)
    raise "Bad Input" unless (good_params = params.slice(*VALID_PARAM_KEYS)).present?
    Hash[good_params.sort].to_param
  end

  def self.hashkey(params)
    raise "Bad Input" unless (good_params = params.slice(*VALID_PARAM_KEYS)).present?
    Digest::SHA1.hexdigest(hash_to_sorted_str(params) + '&'+ ApiConfig.api_key)
  end
end
