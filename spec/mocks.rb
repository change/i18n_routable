class AnyController; end


RSpec.configure do |config|

  config.before do
    ActionDispatch::Routing::RouteSet::Dispatcher.any_instance.stub(:controller_reference).and_return(AnyController)
  end


end

# mock.instance_of(ActionDispatch::Routing::RouteSet::Dispatcher).controller_reference("posts") {PostsController}
