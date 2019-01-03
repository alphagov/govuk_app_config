require 'spec_helper'

# dummy classes which Govuk::Railtie needs
module GovukAppConfig
  class Rails
    def self.env; end
  end

  class Rails::DummyConfig
    def self.after_initialize(&_blk); end

    def self.before_initialize(&_blk); end
  end

  class Rails::Railtie
    def self.initializer(_name, &_blk); end

    def self.config
      Rails::DummyConfig
    end
  end
end

require 'govuk_app_config/railtie'

RSpec.describe GovukAppConfig::Railtie do
  let(:production) { instance_double('production') }
  let(:not_production) { instance_double('not production') }

  before do
    allow(production).to receive(:production?) { true }
    allow(not_production).to receive(:production?) { false }
  end

  describe '#enable_railtie_for?' do
    context 'GOVUK_APP_CONFIG_DISABLE_name_RAILTIE is unset' do
      it 'returns true if in production' do
        allow(GovukAppConfig::Rails).to receive(:env) { production }
        expect(described_class.enable_railtie_for?('foo')).to eql(true)
      end

      it 'returns false if not in production' do
        allow(GovukAppConfig::Rails).to receive(:env) { not_production }
        expect(described_class.enable_railtie_for?('foo')).to eql(false)
      end
    end

    context 'GOVUK_APP_CONFIG_DISABLE_name_RAILTIE is set' do
      it 'returns false if in production' do
        ClimateControl.modify GOVUK_APP_CONFIG_DISABLE_FOO_RAILTIE: 'i am set' do
          allow(GovukAppConfig::Rails).to receive(:env) { production }
          expect(described_class.enable_railtie_for?('foo')).to eql(false)
        end
      end

      it 'returns false if not in production' do
        ClimateControl.modify GOVUK_APP_CONFIG_DISABLE_FOO_RAILTIE: 'i am set' do
          allow(GovukAppConfig::Rails).to receive(:env) { not_production }
          expect(described_class.enable_railtie_for?('foo')).to eql(false)
        end
      end
    end
  end
end
