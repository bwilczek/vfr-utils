require_relative './vfr-utils'
require 'faraday'
require 'nokogiri'
require 'date'

module VfrUtils
  module NOTAM

    URL='https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do'

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
        ret = []
        return VfrUtils.cache.get("notam_#{icao_code}") do
          html = fetch_from_web(icao_code)
          html_doc = Nokogiri::HTML(html)
          html_doc.xpath("//td[@class='textBlack12']/pre").map(&:text).each do |raw_notam|
            ret << parse(raw_notam)
          end
          ret
        end
      end

      private

      def fetch_from_web(icao_code)
        request_params = {
          reportType: 'Raw',
          retrieveLocId: icao_code,
          actionType: 'notamRetrievalByICAOs',
          submit: 'View NOTAMs'
        }
        response = Faraday.post URL, request_params
        response.body
      end

      def parse(raw_notam)
        ret = {
          raw: raw_notam,
          header: nil,
          signature: nil,
          icao_code: nil,
          valid_from: nil,
          valid_to: nil,
          created_at: nil,
          source: nil,
          message: nil
        }

        lines = raw_notam.split("\n")
        ret[:header] = lines[0]
        ret[:created_at] = lines[-2].split(':', 2).last.strip # "17 Nov 2016 10:03:00"
        ret[:created_at] = DateTime.parse(ret[:created_at])
        ret[:source] = lines[-1].split(':', 2).last.strip
        body = lines[1..-3].join(' ').gsub("\n", ' ')

        if matches = body.match(/\AQ\)\s+(?<signature>.+)\s+A\)\s+(?<icao_code>.+)\s+B\)\s+(?<valid_from>.+)\s+C\)\s+(?<valid_to>.+)\s+E\)\s+(?<message>.+)\s*\z/)
          ret[:signature] = matches[:signature]
          ret[:icao_code] = matches[:icao_code]
          ret[:valid_from] = parse_validity_time(matches[:valid_from])
          ret[:valid_to] = parse_validity_time(matches[:valid_to])
          ret[:message] = matches[:message]
        else
          body = ret[:header]+body
          if matches = body.match(/\D(?<valid_from>\d{10})-(?<valid_to>\d{10}([A-Z]{3-5})?|PERM)/)
            ret[:valid_from] = parse_validity_time(matches[:valid_from])
            ret[:valid_to] = parse_validity_time(matches[:valid_to])
            body.gsub!(matches[0], '')
          end
          ret[:message] = body
        end
        ret
      end

      def parse_validity_time(text)
        return DateTime.new(2100) if text == 'PERM'
        year = text[0..1].to_i+2000
        month = text[2..3].to_i
        day = text[4..5].to_i
        hour = text[6..7].to_i
        minute = text[8..9].to_i
        zone = text[10..15]
        DateTime.parse("#{year}-#{month}-#{day} #{hour}:#{minute}:00#{zone}")
      end
    end
  end
end
