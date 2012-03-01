class TestsController < ActionController::Base; end

RSpec.configure do |config|

  config.before do
    ActionDispatch::Routing::RouteSet::Dispatcher.any_instance.stub(:controller_reference).and_return(TestsController)
  end

end
