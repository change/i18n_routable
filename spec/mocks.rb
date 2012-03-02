class TestController < ActionController::Base; end

RSpec.configure do |config|


  config.before do
    allow_message_expectations_on_nil
    ActionDispatch::Routing::RouteSet::Dispatcher.any_instance.stub(:controller_reference).and_return(TestController)
    Rails.application.stub(:env_defaults).and_return(ActionDispatch::TestRequest::DEFAULT_ENV)
    Rails.application.stub(:routes).and_return(SpecRoutes.router)
  end

end
