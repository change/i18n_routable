module I18nRoutable
  module RouteSet
    module LocalizableUrlHelper

    def define_hash_access_with_localize(route, name, kind, options)
      selector = hash_access_name(name, kind)

      # Rails.application.routes.named_routes[:edit_petition]
      i18n_segments = route.segment_keys.find_all{|k| k.to_s =~ /^i18n/}.inject({}){|hash, segment|
        hash.update segment => segment.to_s.match(/^i18n_(.*$)/)[1]
      }

      # We use module_eval to avoid leaks
      @module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{selector}(options = {})                                      # def hash_for_users_url(options = nil)
          route = _routes.named_routes[#{options[:use_route].inspect}]

          base_options = #{options.inspect}

          options[:locale] ||= I18n.locale

          #{i18n_segments.inspect}.each_pair do |option, segment|
            base_options[option] ||= begin
              I18nRoutable.translate_segment(segment, options[:locale])
            end
          end

          if options[:locale] == I18n.default_locale
            options.delete(:locale)
          else
            options[:locale] = I18nRoutable.convert_to_display_locale(options[:locale])
          end

          options.reverse_merge!(base_options)                              #   options ? {:only_path=>false}.merge(options) : {:only_path=>false}

          options
        end                                                                 # end
        protected :#{selector}                                              # protected :hash_for_users_url
      RUBY
      helpers << selector
    end

      def self.included(base)
        base.alias_method_chain :define_hash_access, :localize
      end

    end
  end
end
