require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class OffersControllerTest < ActionController::TestCase

  include Commons

  context "Positive Tests" do
    setup do
      OffersController.any_instance.stubs(:signed?).returns(true)
    end

    teardown do
      OffersController.any_instance.unstub(:signed?)
    end

    should "Instanciate valid number of offers" do
      stub_request(:get, %r{.*sponsorpay.*}).
        to_return(body: body_with_2_offers, :status => 200)

      get :get, pub0: 'x', uid: 'y', page: '1'

      assert assigns(:offers).present?
      assert (o = assigns(:offers)).present? && o.size == 2
    end

    should "Render 'no offers' when no offers returned" do
      stub_request(:get, %r{.*sponsorpay.*}).
        to_return(body: body_with_no_offers, :status => 200)

      get :get, pub0: 'x', uid: 'y', page: '1'

      assert_response :success
      assert assigns(:offers).blank?
      assert_select '.no_offers', 'No Offers'
    end
  end

  context "Negative Tests" do

    context "Response was OK but not signed or invalid body" do

      should "Repond with dignity when server sends invalid json" do
        body = '{"code":"OK","I AM NOT A VAILD JSON", "offers":"I AM NOT VALID JSON!!!"}'
        stub_request(:get, %r{.*sponsorpay.*}).
          to_return(body: body, :status => 200,:headers => {'X-Sponsorpay-Response-Signature' => sign_body(body)})
      end

      should "should have message != nil" do
        body = body_with_2_offers

        stub_request(:get, %r{.*sponsorpay.*}).
          to_return(body: body, :status => 200,:headers => {'X-Sponsorpay-Response-Signature' => sign_body(body, 'fakekey')})

        get :get, pub0: 'x', uid: 'y', page: '1'
        assert_response :success
        assert assigns(:message) =~ /is not signed/i, "no warning message for unsigned response"
      end
    end

    context "Various Errors from Server" do

      setup do
        OffersController.any_instance.stubs(:signed?).returns(true)
      end

      teardown do
        OffersController.any_instance.unstub(:signed?)
      end

      should "raise ActiveResource::UnauthorizedAccess" do
        stub_request(:get, %r{.*sponsorpay.*}).
          to_return(body: '{"code":"ERROR_INVALID_HASHKEY","message":"An invalid hashkey for this appid was given as a parameter in the request."}', 
                    :status => 401)
          get :get, pub0: 'x', uid: 'y', page: '1'
          assert_response :success
          assert assigns(:message) =~ /invalid/, "message does not match with '#{assigns(:message)}'"
      end

      should "raise ActiveResource::BadRequest" do
        stub_request(:get, %r{.*sponsorpay.*}).
          to_return(body: '{"code":"ERROR_INVALID_APPID","message":"An invalid application id (appid) was given as a parameter in the request."}',
                    :status => 400)
          get :get, pub0: 'x', uid: 'y', page: '1'
          assert_response :success
          assert assigns(:message) =~ /invalid/, "message does not match with '#{assigns(:message)}'"
      end

      should "raise ActiveResource::ServerError" do
        stub_request(:get, %r{.*sponsorpay.*}).
          to_return(body: '', :status => 500)
        get :get, pub0: 'x', uid: 'y', page: '1'
        assert_response :success
        assert assigns(:message) =~ /(server)|(500)/i, "message does not match with '#{assigns(:message)}'"
      end
    end
  end

end
