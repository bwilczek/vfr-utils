require_relative 'version'
require_relative 'configuration'
require_relative 'cache'
require_relative 'taf'
require_relative 'notam'
require_relative 'metar'

module VfrUtils
  class << self
    attr_accessor :configuration, :cache
  end

  self.configuration ||= Configuration.new
  self.cache ||= Cache.new

  class << self
    def configure
      self.configuration ||= Configuration.new
      yield configuration
      self.configuration.apply
    end
  end
end
