class RouteTranslationVisitor < ActionDispatch::Journey::Visitors::String

  def route_translations
    @route_translations ||= {}
  end

  def terminal node
    return node unless node.literal?
    localify_node(node)
  end

  private

  def localify_node node
    if translation_requirements = route_constraint_for_segment(node.left)
      tokenized_symbol = I18nRoutable::TranslationAssistant.tokenize_segment(node.left)
      route_translations[tokenized_symbol.to_sym] = translation_requirements
      ":#{tokenized_symbol}"
    else
      node
    end
  end

  def route_constraint_for_segment segment
    I18nRoutable.route_translation_cache[segment]
  end

end
