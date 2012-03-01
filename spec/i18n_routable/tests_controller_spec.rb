require 'spec_helper'
describe 'TestsController' do

  class TestsController < ActionController::Base

    def foo
      url = posts_path :locale => :es
      render :text => url
    end

  end

  it 'should work' do
    TestsController.action_methods.should include('foo')
    env = Rack::MockRequest.env_for('/fr/test')
    response_code, _, response = SpecRoutes.router.call(env)
    response.body.should == '/es/puestos'
    response_code.to_i.should == 200
  end

end
