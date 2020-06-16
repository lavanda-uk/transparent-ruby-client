# frozen_string_literal: true

# This module will expose the API client
module Transparent
  module Constants
    BASE_URI = 'https://listingroiapi.seetransparent.com/'
    ENDPOINT_URIS = {
      aggregated: 'aggregated',
      listings: 'listings'
    }.freeze
  end
end
