class TestController < ActionController::Base; end
class CafeController < ActionController::Base; end
class TestApplication < Rails::Application
  # this is for sessions, which are disabled for this app
  config.secret_key_base = 'aaa'

  # disable sessions
  config.session_store :disabled
end

RSpec.configure do |config|

  config.before do
    I18n.available_locales = SpecRoutes.supported_locales
    I18n.locale = I18n.default_locale
    allow_message_expectations_on_nil
    ActionDispatch::Routing::RouteSet::Dispatcher.any_instance.stub(:controller_reference).and_return(TestController)
    Rails.application.stub(:env_defaults).and_return(ActionDispatch::TestRequest::DEFAULT_ENV)
    Rails.application.stub(:routes).and_return { SpecRoutes.router }
  end

end
