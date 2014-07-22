require 'spec_helper'

describe RouteTranslationVisitor do

  before do
    I18nRoutable.localizing!
  end

  after do
    I18nRoutable.not_localizing!
  end

  context '#terminal' do

    let(:literal) {double(literal?: true)}
    let(:not_literal) {double(literal?: false)}

    it 'should localize terminal segements' do
      subject.stub(:localify_node).with(literal).and_return(:localized)
      subject.terminal(literal).should == :localized
    end

    it 'should not localize other terminal segments' do
      subject.terminal(not_literal).should == not_literal
    end

  end

  context '#localify_node' do

    let(:node) { double(left: 'posts')}

    def localify_node(node)
      subject.send(:localify_node, node)
    end


    it 'should add items to route_translations' do
      localify_node(node).should == ":i18n_posts"
      subject.route_translations.should == {i18n_posts: /posts|puestos|messages/i}
    end

  end


  context '#route_constraint_for_segment' do

    def convert segment
      subject.send :route_constraint_for_segment, segment
    end

    before do
      I18n.stub(:available_locales).and_return %w{fr de nl au}
    end

    it 'should translate in the locales passed in to I18nRoutable' do
      convert("posts").should == /posts|puestos|messages/i
    end

    it 'should regexp escape' do
      convert("all-the-posts").should == /all\-the\-posts|todos\-los\-puestos/i
    end

    it 'should cgi escape' do
      convert("cafe").should == /cafe|caf%C3%A9/i
    end
  end

end
