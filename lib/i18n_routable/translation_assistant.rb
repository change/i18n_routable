module I18nRoutable
  module TranslationAssistant

    def convert_path_to_localized_regexp path
      new_path, segments = '', []
      new_path << path.split(/(\(.+\))/).map do |component|
        unless component.starts_with?("(")
          component.split("/").map do |word|
            if word.blank? || word.starts_with?(":") || word.starts_with?("*")
              word
            else
              segments << word
              ":i18n_#{word.underscore}"
            end
            # CGI.escape(I18n.translate(word, :locale => backend_locale, :scope => 'routes', :default => word))
          end.join("/")
        else
          component
        end
      end.join

      [new_path, segments]
    end

    def add_segment_constraints constraints, segments
      segments.each do |segment|
        constraints[:"i18n_#{segment.underscore}"] ||= route_constraint_for_segment(segment)
      end
    end

    def route_constraint_for_segment segment
      translated_segments = I18nRoutable.backend_locales.map do |locale|
        I18nRoutable.translate_segment(segment, locale)
      end.uniq.map{|s| Regexp.escape(s) }

      Regexp.new translated_segments * '|'
    end

    def translate_segment segment, locale
      CGI.escape I18n.t segment, default: segment, scope: 'routes', locale: locale
    end

  end

  extend TranslationAssistant
end
