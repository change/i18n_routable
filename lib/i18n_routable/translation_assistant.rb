module I18nRoutable
  module TranslationAssistant

    def tokenize_segment segment
      I18nRoutable::TranslationAssistant.tokenize_segment(segment)
    end
    def self.tokenize_segment segment
      "i18n_#{segment}".gsub '-', '__'
    end


    def untokenize_segment segment
      segment.gsub '__', '-'
    end

    # /posts => ["/:i18n_posts", ["posts"]]
    def convert_path_to_localized_regexp path, requirements={}, anchor= true
      spec = Journey::Parser.new.parse(path)
      visitor = RouteTranslationVisitor.new
      new_path = visitor.accept(spec)
      new_requirements = requirements.merge(visitor.route_translations)
      [new_path, new_requirements]
    end

    def translate_segment segment, locale
      segment = untokenize_segment segment
      CGI.escape I18n.t segment, default: segment, scope: 'routes', locale: locale
    end

  end

  extend TranslationAssistant
end
