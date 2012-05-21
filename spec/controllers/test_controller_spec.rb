require 'spec_helper'

class TestController < ActionController::Base

  def foo
    render :text => posts_path(:locale => :es)
  end

  def use_url_for_with_implicit_params

    # url_for should infer the controller from the current controller
    render :text => url_for(:action => 'foo', :only_path => true, :i18n_test => 'prueba', :locale => 'es')

  end

end

describe TestController do

  before do
    @routes = SpecRoutes.router
  end

  it 'should generate the localized urls properly when in a non-default locale' do

    # issue a request to the route for French locale
    env = Rack::MockRequest.env_for('/fr/test')

    # make sure response is good
    response_code, _, response = SpecRoutes.router.call(env)
    response.body.should eql '/es/puestos'
    response_code.to_i.should == 200
  end

  describe "#url_for with implicit parameters when running in controller spec" do

    it 'should work after using a named route in a controller spec example' do

      # run in context of controller with no request, so
      # path parameters are empty
      controller.send(:test_path).should eql '/test'

      # path parameters should be set properly when doing this
      get :use_url_for_with_implicit_params, :i18n_testing_url_for => 'testing_url_for'
      response.body.should == '/es/prueba'
    end

  end

end
