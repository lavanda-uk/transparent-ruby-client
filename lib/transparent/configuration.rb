# frozen_string_literal: true

module Transparent
  class MissingConfiguration < StandardError; end

  # API configuration
  class Configuration
    attr_writer :apikey

    def apikey
      raise MissingConfiguration unless @apikey

      @apikey
    end
  end
end
