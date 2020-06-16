# frozen_string_literal: true

require 'transparent/constants'
require 'transparent/client'

RSpec.describe Transparent::Client do
  let(:req_params) do
    {
      latitude: '51.5099904',
      longitude: '-0.12967951',
      radius_meters: 1000,
      type: 'ENTIRE_HOME',
      subtype: 'APARTMENT'
    }
  end

  context '#aggregated' do
    context 'when API returns OK response' do
      let(:body) { '' }
      let(:http_status) { 200 }
      let(:expected_http_req) do
        stub_request(
          :get,
          Transparent::Constants::BASE_URI + Transparent::Constants::ENDPOINT_URIS[:aggregated]
        ).with(
          query: req_params,
          headers: {
            'Expect'=>'',
            'User-Agent'=>'Typhoeus - https://github.com/typhoeus/typhoeus'
          }
        ).to_return(status: http_status, body: body, headers: {})
      end

      it 'requests aggregated pricing via http' do
        expected_http_req

        described_class.new.aggregated(req_params)

        assert_requested(expected_http_req)
      end

      context 'when API returns empty body response' do
        it 'returns nil' do
          expected_http_req

          expect(
            described_class.new.aggregated(req_params)
          ).to be_nil
        end
      end

      context 'when API returns contentful response' do
        let(:body) { File.read('spec/simulated_api_responses/dataful/aggregated.json') }

        it 'fetches aggregated pricing data' do
          expected_http_req

          expect(described_class.new.aggregated(req_params)).to eq(
            adr: 318,
            occupancy: 0.36000001430511475
          )
        end
      end
    end
  end
end
