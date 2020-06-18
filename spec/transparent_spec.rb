# typed: false
# frozen_string_literal: true

require 'transparent'

RSpec.describe Transparent do
  let(:api_key) { 'API_KEY' }

  describe 'configuration' do
    context 'with configuration block' do
      before do
        Transparent.configure do |config|
          config.apikey = api_key
        end
      end

      it 'returns the correct apikey' do
        expect(Transparent.configuration.apikey).to eq(api_key)
      end
    end

    context 'without configuration block' do
      it 'raises a configuration error for apikey' do
        Transparent.configuration.apikey = nil

        expect { Transparent.configuration.apikey }.to raise_error(
          Transparent::MissingConfiguration
        )
      end
    end
  end
end
