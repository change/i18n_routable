class MyVisitor < Journey::Visitors::String

  def changes
    @changes ||= {}
  end

  def terminal node
    return node unless node.literal?
    localify_node(node)
  end

  def localify_node node
    if translation_requirements = route_constraint_for_segment(node.left)
      tokenized_symbol = I18nRoutable::TranslationAssistant.tokenize_segment(node.left)
      changes[tokenized_symbol.to_sym] = translation_requirements
      ":#{tokenized_symbol}"
    else
      node
    end
  end

  def visit_STAR node
    "*#{unary(node)}"
  end

  def route_constraint_for_segment segment
    I18nRoutable.route_translation_cache[segment]
  end


end


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
      visitor = MyVisitor.new
      new_path = visitor.accept(spec)
      new_requirements = requirements.merge(visitor.changes)
      [new_path, new_requirements]
    end

    def translate_segment segment, locale
      segment = untokenize_segment segment
      CGI.escape I18n.t segment, default: segment, scope: 'routes', locale: locale
    end

  end

  extend TranslationAssistant
end
