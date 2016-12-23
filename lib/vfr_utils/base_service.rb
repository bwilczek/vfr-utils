require_relative '../vfr_utils'
require 'faraday'
require 'nokogiri'
require 'date'

module VfrUtils
  class BaseService

    class << self

      def inherited(child_class)
        def child_class.cache
          unless @cache
            config_key = self.name.split('::').last.downcase.to_sym
            @cache = Cache.new(VfrUtils.master_configuration.send(config_key))
          end
          @cache
        end
      end

      def get(icao_codes)
        icao_codes = [*icao_codes]
        icao_codes.map!(&:upcase)

        ret = {}
        icao_codes.each do |icao_code|
          ret[icao_code] = get_one(icao_code)
        end
        ret
      end

      def get_one(icao_code)
        raise "Implement me!"
      end

    end
  end
end
