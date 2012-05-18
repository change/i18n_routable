require 'rails/all'
require 'active_support/all'

# require 'i18n_routable/version'
# require 'i18n_routable/config'
# require 'i18n_routable/mapper'
require 'i18n_routable/route_set'
# require 'i18n_routable/route_set/reverse_route_lookup'
# require 'i18n_routable/url_options_override'

module I18nRoutable
  module MatchWithLocalize

    def self.included base
      base.alias_method_chain :match, :localize
    end

    def match_with_localize path, options={}
      options ||= {}

      path, segments = I18nRoutable.convert_path_to_localized_regexp(path)

      if segments.present?
        options[:constraints] ||= {}
        if options[:constraints].is_a? Hash
          I18nRoutable.add_segment_constraints(options[:constraints], segments)
        end
      end

      match_without_localize(path, options)
    end

  end

  def self.convert_path_to_localized_regexp path
    new_path, segments = '', []
    new_path << path.split(/(\(.+\))/).map do |component|
      unless component.starts_with?("(")
        component.split("/").map do |word|
          if word.blank? || word.starts_with?(":")
            word
          else
            segments << word
            ":i18n_#{word}"
          end
          # CGI.escape(I18n.translate(word, :locale => backend_locale, :scope => 'routes', :default => word))
        end.join("/")
      else
        component
      end
    end.join

    [new_path, segments]
  end

  def self.add_segment_constraints constraints, segments
    segments.each_with_index{|segment, index|
      constraints[:"i18n_#{segment}"] ||= route_constraint_for_segment(segment, index)
    }
  end

  def self.route_constraint_for_segment segment, index
    translated_segments = I18n.available_locales.map{|locale|
      translated_segment = I18nRoutable.translate_segment(segment, locale)
      index == 0 && locale != I18n.default_locale ? "#{locale}/#{translated_segment}" : translated_segment
    }.uniq.map{|s| Regexp.escape(s) }

    Regexp.new translated_segments * '|'
  end

  def self.translate_segment segment, locale
    CGI.escape I18n.t segment, default: segment, scope: 'routes', locale: locale
  end

end

ActionDispatch::Routing::Mapper::Base.send :include, I18nRoutable::MatchWithLocalize


class ActionDispatch::Routing::RouteSet::NamedRouteCollection

  def define_hash_access(route, name, kind, options)
    selector = hash_access_name(name, kind)

    # Rails.application.routes.named_routes[:edit_petition]
    i18n_segments = route.segment_keys.find_all{|k| k.to_s =~ /^i18n/}.inject({}){|hash, segment|
      hash.update segment => segment.to_s.match(/^i18n_(.*$)/)[1]
    }

    # We use module_eval to avoid leaks
    @module.module_eval <<-END_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(options = {})                                      # def hash_for_users_url(options = nil)
        route = _routes.named_routes[#{options[:use_route].inspect}]

        base_options = #{options.inspect}

        locale = options.delete(:locale) || I18n.locale
        #{i18n_segments.inspect}.each_with_index{|(option, segment), index|
          base_options[option] ||= begin
            translated_segment = I18nRoutable.translate_segment(segment, locale)
            index == 0 && locale != I18n.default_locale ? "\#{locale}/\#{translated_segment}" : translated_segment
          end
        }

        options.reverse_merge!(base_options)                              #   options ? {:only_path=>false}.merge(options) : {:only_path=>false}

        options
      end                                                                 # end
      protected :#{selector}                                              # protected :hash_for_users_url
    END_EVAL
    helpers << selector
  end
end
