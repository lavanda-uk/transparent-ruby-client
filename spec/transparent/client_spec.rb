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
            'Expect' => '',
            'User-Agent' => 'Typhoeus - https://github.com/typhoeus/typhoeus'
          }
        ).to_return(status: http_status, body: body, headers: {})
      end

      it 'requests aggregated pricing via http' do
        expected_http_req

        described_class.new(**req_params).aggregated

        assert_requested(expected_http_req)
      end

      context 'when API returns empty body response' do
        it 'returns nil' do
          expected_http_req

          expect(
            described_class.new(**req_params).aggregated
          ).to be_nil
        end
      end

      context 'when API returns contentful response' do
        let(:body) { File.read('spec/simulated_api_responses/dataful/aggregated.json') }

        it 'fetches aggregated pricing data' do
          expected_http_req

          expect(described_class.new(**req_params).aggregated).to eq(
            adr: 318,
            occupancy: 0.36000001430511475
          )
        end
      end
    end
  end

  context '#combined' do
    context 'when API returns OK responses' do
      let(:listings_body) { '' }
      let(:listings_http_status) { 200 }
      let(:expected_listings_http_req) do
        stub_request(
          :get,
          Transparent::Constants::BASE_URI + Transparent::Constants::ENDPOINT_URIS[:listings]
        ).with(
          query: req_params,
          headers: {
            'Expect' => '',
            'User-Agent' => 'Typhoeus - https://github.com/typhoeus/typhoeus'
          }
        ).to_return(status: listings_http_status, body: listings_body, headers: {})
      end

      let(:aggregated_body) { '' }
      let(:aggregated_http_status) { 200 }
      let(:expected_aggregated_http_req) do
        stub_request(
          :get,
          Transparent::Constants::BASE_URI + Transparent::Constants::ENDPOINT_URIS[:aggregated]
        ).with(
          query: req_params,
          headers: {
            'Expect' => '',
            'User-Agent' => 'Typhoeus - https://github.com/typhoeus/typhoeus'
          }
        ).to_return(status: aggregated_http_status, body: aggregated_body, headers: {})
      end

      before do
        expected_listings_http_req && expected_aggregated_http_req
      end

      it 'requests aggregated and listings pricing via http' do
        described_class.new(**req_params).combined

        assert_requested(expected_listings_http_req)
        assert_requested(expected_aggregated_http_req)
      end

      context 'when API returns empty body responses' do
        it 'returns nil' do
          expect(
            described_class.new(**req_params).combined
          ).to be_nil
        end
      end

      context 'when API returns contentful responses' do
        let(:aggregated_body) { File.read('spec/simulated_api_responses/dataful/aggregated.json') }
        let(:listings_body) { File.read('spec/simulated_api_responses/dataful/listings.json') }

        it 'fetches combined pricing data' do
          expect(described_class.new(**req_params).combined).to eq(
            adr: 318,
            occupancy: 0.36000001430511475,
            listings: [
              { adr: 112.98418972332016, occupancy: 0.36 }
            ]
          )
        end
      end
    end
  end
end
