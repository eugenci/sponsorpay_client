class OffersController < ApplicationController

  include Commons

  def new; end

  def get
    @message = begin
      @offers = Offer.find(:all, params: pa_prepare(params))
      'Response is not signed.' unless signed?
    rescue *SERVICE_ERRORS => e
      # parse json error messge
      resp = decode_service_response(e)
      resp.present? ? resp['message'] : e.message
    end
  end

  private

  SERVICE_ERRORS = [ ActiveResource::UnauthorizedAccess,
                     ActiveResource::BadRequest,
                     ActiveResource::ServerError,
                     ActiveResource::ForbiddenAccess,
                     ActiveResource::ResourceNotFound ]

  # i.e. prepare params for fetching offer
  def pa_prepare(params)
    Offer.prepare_params(params.slice(:pub0, :uid, :page))
  end

  def signed?
    x_sponsor_pay_signature == correct_signature
  end

  def correct_signature
    # defined in lib/commons
    sign_body(Offer.connection.http_response.body)
  end

  def x_sponsor_pay_signature
    # check out ActiveResource-response gem
    Offer.connection.http_response.to_hash['x-sponsorpay-response-signature'].first
  end

  def decode_service_response(e)
    return JSON.parse(e.response.body)
  rescue
    Rails.logger.warn "Service returned invalid JSON! -#{e.response.body}-"
    return nil
  end
end
