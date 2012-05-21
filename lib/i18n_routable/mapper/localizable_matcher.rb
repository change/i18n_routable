module I18nRoutable
  module Mapper
    module LocalizableMatcher

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

    def self.included base
      base.alias_method_chain :match, :localize
    end


    end
  end
end
