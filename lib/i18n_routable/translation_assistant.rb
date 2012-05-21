module I18nRoutable
  module TranslationAssistant

    def convert_path_to_localized_regexp path
      return [path,[]] if path =~ %r{^/+$} # Root url

      new_path, segments = '', []

      new_path << path.split(/(\(.+\))/).map do |component|
        if component.starts_with?("(") || component == '//'
          component
        else
          component.split("/").map do |word|
            if word.blank? || word.starts_with?(":") || word.starts_with?("*") || translated_segments(word) == [word]
              word
            else
              segments << word
              ":i18n_#{word.underscore}"
            end
          end.join("/")
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
      Regexp.new translated_segments(segment).map{|s| Regexp.escape(s) } * '|'
    end

    def translated_segments segment
      I18nRoutable.backend_locales.map do |locale|
        I18nRoutable.translate_segment(segment, locale)
      end.uniq
    end

    def translate_segment segment, locale
      CGI.escape I18n.t segment, default: segment, scope: 'routes', locale: locale
    end

  end

  extend TranslationAssistant
end
