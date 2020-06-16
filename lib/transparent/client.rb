# frozen_string_literal: true

module Transparent
  # API wrapper/client
  class Client
    def aggregated(latitude:, longitude:, radius_meters:, type:, subtype:)
      response = Typhoeus.get(
        Constants::BASE_URI + Constants::ENDPOINT_URIS[:aggregated],
        params: {
          latitude: latitude,
          longitude: longitude,
          radius_meters: radius_meters,
          type: type,
          subtype: subtype
        }
      )

      return if response.body.empty?

      object = JSON.parse(response.body)

      {
        adr: object['year_average_adr'],
        occupancy: object['year_average_occupancy']
      }
    end
  end
end
