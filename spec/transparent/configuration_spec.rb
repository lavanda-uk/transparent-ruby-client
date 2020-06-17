# frozen_string_literal: true

require 'transparent/configuration'

module Transparent
  RSpec.describe Configuration do
    it 'allows apikey to be written into configuration' do
      aggregate_failures do
        subject.apikey = 'something'
        expect(subject.apikey).to eq('something')
        subject.apikey = 'something else'
        expect(subject.apikey).to eq('something else')
      end
    end

    context 'when the apikey was not configured before hand' do
      it 'raises an exception' do
        expect { subject.apikey }.to raise_error(MissingConfiguration)
      end
    end
  end
end
