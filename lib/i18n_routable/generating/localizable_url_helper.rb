module I18nRoutable
  module Generating
    module LocalizableUrlHelper

      # we override this, but it really only removes positional_keys that are
      # locale or i18n_*
      def define_url_helper_with_localize(mod, route, name, opts, route_key, kind)
        # #selector = url_helper_name(name, kind)
        # selector = :"#{name}_#{kind}"
        # #hash_access_method = hash_access_name(name, kind)
        # hash_access_method = :"hash_for_#{name}_#{kind}"
        positional_segments = route.segment_keys.reject do |key|
          key == :locale || key.to_s.starts_with?("i18n_")
        end
        #
        # mod.module_eval <<-END_EVAL, __FILE__, __LINE__ + 1
        #   def #{selector}(*args)
        #     options =  #{hash_access_method}(args.extract_options!)
        #
        #     unless args.empty?
        #       options[:_positional_args] = args
        #       options[:_positional_keys] = #{positional_segments.inspect}
        #     end
        #
        #     url_for(options)
        #   end
        # END_EVAL
        # helpers << selector

        helper = ActionDispatch::Routing::RouteSet::NamedRouteCollection::UrlHelper.create(route, opts, route_key, kind)
        mod.module_eval do
          define_method(name) do |*args|
            options = {}
            options = args.pop if args.last.is_a? Hash

            unless args.empty?
              options[:_positional_args] = args
              options[:_positional_keys] = positional_segments.inspect
            end

            helper.call self, args, options
          end
        end
      end

      def self.included(base)
        base.alias_method_chain :define_url_helper, :localize
      end

    end
  end
end
