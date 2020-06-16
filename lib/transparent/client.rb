# frozen_string_literal: true

module Transparent
  # API wrapper/client
  class Client
    def initialize(latitude:, longitude:, radius_meters:, type:, subtype:)
      @latitude = latitude
      @longitude = longitude
      @radius_meters = radius_meters
      @type = type
      @subtype = subtype
    end

    def aggregated
      aggregated_request.run

      return if aggregated_response.body.empty?

      {
        adr: aggregated_object['year_average_adr'],
        occupancy: aggregated_object['year_average_occupancy']
      }
    end

    def combined
      parallel_listings_and_aggregated_requests.run

      return unless both_responses_have_content?

      {
        adr: aggregated_object['year_average_adr'],
        occupancy: aggregated_object['year_average_occupancy'],
        listings: listings_object.map do |listing|
          {
            adr: listing['year_total_revenue'].to_f / listing['active_days'],
            occupancy: listing['year_total_occupancy']
          }
        end
      }
    end

    private

    attr_reader :latitude, :longitude, :radius_meters, :type, :subtype

    def both_responses_have_content?
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
        params: {
          latitude: latitude,
          longitude: longitude,
          radius_meters: radius_meters,
          type: type,
          subtype: subtype
        }
      )
    end

    def aggregated_request
      @aggregated_request ||= Typhoeus::Request.new(
        Constants::BASE_URI + Constants::ENDPOINT_URIS[:aggregated],
        method: :get,
        params: {
          latitude: latitude,
          longitude: longitude,
          radius_meters: radius_meters,
          type: type,
          subtype: subtype
        }
      )
    end
  end
end
