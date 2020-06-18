# typed: true
# frozen_string_literal: true

require 'transparent/constants'

module Transparent
  # API wrapper/client
  class Client
    def initialize(
      latitude:,
      longitude:,
      radius_meters:,
      type:,
      subtype:,
      bedrooms: [],
      bathrooms: [],
      capacity: [],
      pool: nil,
      air_conditioning: nil,
      kid_friendly: nil,
      parking: nil,
      hot_tub: nil,
      active_days: nil
    )
      @latitude = latitude
      @longitude = longitude
      @radius_meters = radius_meters
      @type = type
      @subtype = subtype

      @optional_params = {
        bedrooms: bedrooms.join(','),
        bathrooms: bathrooms.join(','),
        capacity: capacity.join(','),
        pool: normalise_boolean(pool),
        air_conditioning: normalise_boolean(air_conditioning),
        kid_friendly: normalise_boolean(kid_friendly),
        parking: normalise_boolean(parking),
        hot_tub: normalise_boolean(hot_tub),
        active_days: active_days
      }.select do |_key, value|
        value && !value.to_s.empty?
      end
    end

    def aggregated
      aggregated_request.run

      return { fulfilled: false } if aggregated_response.body.empty? || !aggregated_response.success?

      {
        fulfilled: true,
        data: {
          adr: aggregated_object['year_average_adr'],
          occupancy: aggregated_object['year_average_occupancy']
        }
      }
    end

    def combined
      parallel_listings_and_aggregated_requests.run

      return { fulfilled: false } unless both_responses_are_good?

      {
        fulfilled: true,
        data: {
          adr: aggregated_object['year_average_adr'],
          occupancy: aggregated_object['year_average_occupancy'],
          listings: listings_object.map do |listing|
            {
              adr: listing['year_total_revenue'].to_f / listing['active_days'],
              occupancy: listing['year_total_occupancy']
            }
          end
        }
      }
    end

    private

    attr_reader :latitude, :longitude, :radius_meters, :type, :subtype, :optional_params

    def normalise_boolean(value)
      return nil unless value

      !!value ? 1 : 0
    end

    def both_responses_are_good?
      [aggregated_response, listings_response].all?(&:success?) &&
        [aggregated_response, listings_response].none? { |r| r.body.empty? }
    end

    def parallel_listings_and_aggregated_requests
      return @hydra if @hydra

      @hydra = Typhoeus::Hydra.new
      @hydra.queue(listings_request)
      @hydra.queue(aggregated_request)
      @hydra
    end

    def aggregated_object
      @aggregated_object ||= JSON.parse(aggregated_response.body)
    end

    def listings_object
      @listings_object ||= JSON.parse(listings_response.body)
    end

    def aggregated_response
      @aggregated_response ||= aggregated_request.response
    end

    def listings_response
      @listings_response ||= listings_request.response
    end

    def listings_request
      @listings_request ||= Typhoeus::Request.new(
        Constants::BASE_URI + Constants::ENDPOINT_URIS[:listings],
        method: :get,
        headers: {
          apikey: Transparent.configuration.apikey
        },
        params: {
          latitude: latitude,
          longitude: longitude,
          radius_meters: radius_meters,
          type: type,
          subtype: subtype
        }.merge(optional_params)
      )
    end

    def aggregated_request
      @aggregated_request ||= Typhoeus::Request.new(
        Constants::BASE_URI + Constants::ENDPOINT_URIS[:aggregated],
        method: :get,
        headers: {
          apikey: Transparent.configuration.apikey
        },
        params: {
          latitude: latitude,
          longitude: longitude,
          radius_meters: radius_meters,
          type: type,
          subtype: subtype
        }.merge(optional_params)
      )
    end
  end
end
