require_relative '../vfr_utils'
require 'faraday'
require 'nokogiri'
require 'date'

module VfrUtils
  class TAF < BaseService

    URL='http://aviationweather.gov/taf/data'

    class << self

      def get_one(icao_code)
        return cache.get("taf_#{icao_code}") do
          html = fetch_from_web(icao_code)
          parse(html)
        end
      end

      private

      def fetch_from_web(icao_code)
        # http://aviationweather.gov/taf/data?ids=EPWR&format=raw&metars=off&layout=off
        request_params = {
          ids: icao_code,
          format: 'raw',
          metars: 'off',
          layout: 'off',
        }
        response = Faraday.get URL, request_params
        response.body
      end

      def parse(html)
        html_doc = Nokogiri::HTML(html)
        begin
          data = html_doc.xpath("//code").first.inner_html.gsub('<br>', "\n")
        rescue
          data = nil
        end
        { data: data }
      end

    end
  end
end
