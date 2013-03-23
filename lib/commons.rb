module Commons
  def sign_body(body, key = ApiConfig.api_key)
    Digest::SHA1.hexdigest(body+key)
  end
end
