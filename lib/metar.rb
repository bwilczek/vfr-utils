require_relative './vfr-utils'
require 'faraday'
require 'nokogiri'
require 'date'

module VfrUtils
  module METAR

    URL='http://aviationweather.gov/metar/data'

    class << self

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
        return VfrUtils.cache.get("metar_#{icao_code}") do
          html = fetch_from_web(icao_code)
          parse(html)
        end
      end

      private

      def fetch_from_web(icao_code)
        request_params = {
          ids: icao_code,
          format: 'raw',
          hours: 0,
          taf: 'off',
          layout: 'off',
          date: 0
        }
        response = Faraday.get URL, request_params
        response.body
      end

      def parse(html)
        html_doc = Nokogiri::HTML(html)
        { data: html_doc.xpath("//div[@id='awc_main_content']//p").first.text }
      end

    end
  end
end
