require File.expand_path("../spec/spec_helper", __FILE__)

class ActionDispatch::Routing::RouteSet::Dispatcher
  def controller_reference controller
    TestController
  end
end

TIMES = 10000

def resolve(path, http_verb=:get)
  SpecRoutes.router.recognize_path(path, {:method => http_verb})
end

class RouteGenerator
  include SpecRoutes.router.url_helpers

  def benchmark_no_translations!
    blogs_path # no translations in routes.yml
  end

  def benchmark_with_translations!
    edit_post_comment_url locale: 'es', post_id: 1, id: 2
  end
end

@route_generator = RouteGenerator.new

Benchmark.bmbm do |x|
  x.report 'recognizing urls' do
    TIMES.times do
      hash = resolve("/fr/messages/hello-there/commentaires/the-comment-id/modifier")
      raise hash.inspect unless hash.present?
    end
  end

  x.report 'generating urls with no translation options' do
    TIMES.times do
      path = @route_generator.benchmark_no_translations!
      raise path unless path.present?
    end
  end

  x.report 'generating urls with translation options' do
    TIMES.times do
      path = @route_generator.benchmark_with_translations!
      raise path unless path.present?
    end
  end
end
