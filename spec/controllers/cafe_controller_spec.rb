# encoding: utf-8
require 'spec_helper'

class CafeController < ActionController::Base

  def drink
    I18n.locale = params[:locale]
    render :text => cafe_path
  end

end

describe CafeController do

  before do
    @routes = SpecRoutes.router
  end

  it 'should allow for utf characters' do
    get :drink, i18n_cafe: 'café', locale: :es
    response.body.should eq '/es/caf%C3%A9'
  end
end
