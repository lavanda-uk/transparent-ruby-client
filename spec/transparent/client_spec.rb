# typed: false
# frozen_string_literal: true

require 'transparent/constants'
require 'transparent/client'

RSpec.describe Transparent::Client do
  before do
    Transparent.configure do |config|
      config.apikey = 'fake-api-key'
    end
  end

  let(:req_params) do
    {
      latitude: '51.5099904',
      longitude: '-0.12967951',
      radius_meters: 1000,
      type: 'ENTIRE_HOME',
      subtype: 'APARTMENT'
    }
  end

  let(:expected_query_params) { req_params }

  context '#aggregated' do
    let(:body) { '' }
    let(:expected_http_req) do
      stub_request(
        :get,
        Transparent::Constants::BASE_URI + Transparent::Constants::ENDPOINT_URIS[:aggregated]
      ).with(
        query: expected_query_params,
        headers: {
          'Expect' => '',
          'User-Agent' => 'Typhoeus - https://github.com/typhoeus/typhoeus'
        }
      ).to_return(status: http_status, body: body, headers: {})
    end

    before do
      expected_http_req
    end

    context 'when optional params are passed' do
      let(:req_params) do
        {
          latitude: '51.5099904',
          longitude: '-0.12967951',
          radius_meters: 1000,
          type: 'ENTIRE_HOME',
          subtype: 'APARTMENT',
          bedrooms: [3, 4, 5],
          capacity: [8, 9],
          bathrooms: [2, 3, 4],
          active_days: nil,
          hot_tub: '',
          parking: true,
          kid_friendly: nil,
          air_conditioning: false
        }
      end

      let(:http_status) { 200 }
      let(:expected_http_req) do
        stub_request(
          :get,
          Transparent::Constants::BASE_URI + Transparent::Constants::ENDPOINT_URIS[:aggregated] +
          '?bathrooms=2,3,4&bedrooms=3,4,5&capacity=8,9&hot_tub=1&latitude=51.5099904&' \
          'longitude=-0.12967951&parking=1&radius_meters=1000&subtype=APARTMENT&type=ENTIRE_HOME'
        ).with(
          headers: {
            'Expect' => '',
            'User-Agent' => 'Typhoeus - https://github.com/typhoeus/typhoeus'
          }
        ).to_return(status: http_status, body: body, headers: {})
      end

      it 'removes nil or empty params and transforms list params' do
        described_class.new(**req_params).aggregated

        assert_requested(expected_http_req)
      end
    end

    context 'when API produces an error response' do
      [400, 404, 500, 503].each do |http_status|
        let(:http_status) { http_status }
        let(:body) { { error: 'message' }.to_json }

        it 'returns unfulfillable response' do
          expect(
            described_class.new(**req_params).aggregated[:fulfilled]
          ).to eq(false)
        end
      end
    end

    context 'when API returns OK response' do
      let(:http_status) { 200 }

      it 'requests aggregated pricing via http' do
        described_class.new(**req_params).aggregated

        assert_requested(expected_http_req)
      end

      context 'when API returns empty body response' do
        it 'returns nil' do
          expect(
            described_class.new(**req_params).aggregated[:fulfilled]
          ).to eq(false)
        end
      end

      context 'when API returns contentful response' do
        let(:body) { File.read('spec/simulated_api_responses/dataful/aggregated.json') }

        it 'fetches aggregated pricing data' do
          expect(described_class.new(**req_params).aggregated[:fulfilled]).to eq(true)

          expect(described_class.new(**req_params).aggregated[:data]).to eq(
            adr: 318,
            occupancy: 0.36000001430511475
          )
        end
      end
    end
  end

  context '#combined' do
    let(:listings_body) { '' }
    let(:listings_http_status) { 200 }
    let(:expected_listings_http_req) do
      stub_request(
        :get,
        Transparent::Constants::BASE_URI + Transparent::Constants::ENDPOINT_URIS[:listings]
      ).with(
        query: expected_query_params,
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
        query: expected_query_params,
        headers: {
          'Expect' => '',
          'User-Agent' => 'Typhoeus - https://github.com/typhoeus/typhoeus'
        }
      ).to_return(status: aggregated_http_status, body: aggregated_body, headers: {})
    end

    before do
      expected_listings_http_req && expected_aggregated_http_req
    end

    context 'when API produces at least one error response' do
      [400, 404, 500, 503].each do |http_status|
        let(:aggregated_http_status) { http_status }
        let(:aggregated_body) { { error: 'message' }.to_json }

        it 'returns unfulfillable response' do
          expect(
            described_class.new(**req_params).combined[:fulfilled]
          ).to eq(false)
        end
      end
    end

    context 'when API returns OK responses' do
      it 'requests aggregated and listings pricing via http' do
        described_class.new(**req_params).combined

        assert_requested(expected_listings_http_req)
        assert_requested(expected_aggregated_http_req)
      end

      context 'when API returns empty body responses' do
        it 'returns nil' do
          expect(
            described_class.new(**req_params).combined[:fulfilled]
          ).to eq(false)
        end
      end

      context 'when API returns contentful responses' do
        let(:aggregated_body) { File.read('spec/simulated_api_responses/dataful/aggregated.json') }
        let(:listings_body) { File.read('spec/simulated_api_responses/dataful/listings.json') }

        it 'fetches combined pricing data' do
          expect(described_class.new(**req_params).combined[:fulfilled]).to eq(true)
          expect(described_class.new(**req_params).combined[:data]).to eq(
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
