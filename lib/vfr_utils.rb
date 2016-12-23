require_relative 'vfr_utils/version'
require_relative 'vfr_utils/configuration'
require_relative 'vfr_utils/master_configuration'
require_relative 'vfr_utils/cache'
require_relative 'vfr_utils/base_service'
require_relative 'vfr_utils/taf'
require_relative 'vfr_utils/notam'
require_relative 'vfr_utils/metar'

module VfrUtils
  class << self
    attr_accessor :master_configuration
  end

  self.master_configuration ||= MasterConfiguration.new

  class << self
    def configure
      self.master_configuration ||= MasterConfiguration.new
      yield master_configuration
    end
  end
end
