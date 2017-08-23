require 'spec_helper'
require 'govuk_config/statsd'

RSpec.describe GOVUK::Statsd do
  describe '#increment' do
    it 'increments the counter' do
      expect {
        GOVUK::Statsd.increment("some.key")
      }.not_to raise_error
    end
  end
end
