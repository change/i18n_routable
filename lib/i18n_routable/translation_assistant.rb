
module I18nRoutable
  module TranslationAssistant

    def tokenize_segment segment
      "i18n_#{segment}".gsub '-', '__'
    end

    def untokenize_segment segment
      segment.gsub '__', '-'
    end

    # /posts => ["/:i18n_posts", ["posts"]]
    def convert_path_to_localized_regexp path
      new_path, i18n_segment, segments = '', '', []
      prefixes = Hash.new {|h,k| h[k] = ''}
      prefixes.merge! :PARAM => ':', :GLOB => '*'
      route_lexer = ::Rack::Mount::StrexpParser.new.tap {|s| s.scan_setup path }
      route_separators = /[#{ActionDispatch::Routing::SEPARATORS.join ''}]/
      begin
        type, token = route_lexer.next_token
        # puts "RES: %6s : %s" % [type, token]

        if type == :CHAR && token !~ route_separators
          i18n_segment << token
          next
        end

        if i18n_segment.present?
          # Only add it to be translated if there are translations
          if I18nRoutable.route_translation_cache[i18n_segment]
            new_path << ":#{tokenize_segment i18n_segment}"
            segments << i18n_segment
          else
            new_path << i18n_segment
          end
        end

        i18n_segment = ''
        new_path << prefixes[type] << token if token
      end while type.present?

      [new_path, segments]
    end



    def add_segment_constraints constraints, segments
      segments.each do |segment|
        constraint_token = tokenize_segment segment
        constraints[constraint_token.to_sym] ||= route_constraint_for_segment(segment)
      end
    end

    def route_constraint_for_segment segment
      I18nRoutable.route_translation_cache[segment]
    end

    def translate_segment segment, locale
      segment = untokenize_segment segment
      CGI.escape I18n.t segment, default: segment, scope: 'routes', locale: locale
    end

  end

  extend TranslationAssistant
end
