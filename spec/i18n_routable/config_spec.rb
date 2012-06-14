
require 'spec_helper'
describe I18nRoutable::Config do

  context 'validating config options' do
    before do
      @old_config = I18nRoutable.localize_config
    end

    after do
      I18nRoutable.localize_config = @old_config
    end

    it 'should not support a symbol for :locales, it must take an array' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => :fr
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support invalid options' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :foo => :boo
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support any strings for locales in a value' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => { :gibberish => 'hey' }
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support any strings for locales in a key' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => { 'gibberish' => :hey }
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support any strings for stand alone locales' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => [{:gibberish => :hey}, 'es']
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'should not support any locale hashes with multiple key/value pairs' do
      lambda do
        SpecRoutes.always_new_router.draw do
          localize! :locales => [{:gibberish => :hey, :not => :supported}, :es]
          resources :dogs
        end
      end.should raise_error(ArgumentError)
    end

    it 'does not require loading of translations if a locale is specified' do
      I18n.should_not_receive(:available_locales)
      SpecRoutes.always_new_router.draw do
        localize! locales: [:es]
        resources :dogs
      end
    end

    context 'passing translations' do

      before {
        @translations = YAML.load_file(SpecRoutes.routes_yml)
        @locales = @translations.keys.map(&:to_sym)
        I18n.should_not_receive(:translate)
      }

      def verify_successful_localization
        translations = @translations
        locales = @locales

        SpecRoutes.always_new_router.draw do
          localize! translations: translations, locales: locales
          localize do
            resources :dogs
          end
        end

      end

      it 'does not require loading of translations if a translations are specified' do

        verify_successful_localization
      end

      it 'does not choke when no translations are present for a locale' do
        @locales << :'another locale'
        verify_successful_localization
      end

    end
  end
end
