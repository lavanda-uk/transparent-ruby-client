# typed: true
# frozen_string_literal: true

require_relative 'transparent/configuration'
require_relative 'transparent/client'

# This module will expose the API client
module Transparent
  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end
