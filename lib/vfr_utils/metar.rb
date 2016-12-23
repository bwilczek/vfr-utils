require_relative '../vfr_utils'
require 'faraday'
require 'nokogiri'
require 'date'

module VfrUtils
  class METAR < BaseService

    URL='http://aviationweather.gov/metar/data'

    class << self

      def get_one(icao_code)
        return cache.get("metar_#{icao_code}") do
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
        begin
          data = html_doc.xpath("//div[@id='awc_main_content']//p").first.next_sibling.next_sibling.next_sibling.text
        rescue
          data = nil
        end
        { data: data }
      end

    end
  end
end
