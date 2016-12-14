require 'faraday'
require 'nokogiri'
require 'date'

require_relative './notam/configuration'

module VfrUtils
  module NOTAM

    class << self
      attr_accessor :configuration
    end

    self.configuration ||= Configuration.new

    class << self

      def configure
        self.configuration ||= Configuration.new
        yield configuration
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
        raw_notams = fetch(icao_code)
        ret = []
        raw_notams.each do |raw_notam|
          ret << parse(raw_notam)
        end
        ret
      end

      private

      def prepare_cache_file(icao_code)
        FileUtils.mkdir_p configuration.cache_directory
        cache_file_path = "#{configuration.cache_directory}/notam_#{icao_code}.tmp"

        # expire cache
        if File.exists?(cache_file_path)
          FileUtils.rm_rf(cache_file_path) if Time.now.to_i - File.ctime(cache_file_path).to_i > configuration.cache_lifetime
        end
        cache_file_path
      end

      # Return Array of raw NOTAM messages
      def fetch(icao_code)
        cache_file_path = prepare_cache_file(icao_code)
        unless File.exists?(cache_file_path)
          fetch_from_web_and_cache(icao_code, cache_file_path)
        end

        html_doc = Nokogiri::HTML(File.read(cache_file_path))
        html_doc.xpath("//td[@class='textBlack12']/pre").map(&:text)
      end

      def fetch_from_web_and_cache(icao_code, cache_file_path)
        request_params = {
          reportType: 'Raw',
          retrieveLocId: icao_code,
          actionType: 'notamRetrievalByICAOs',
          submit: 'View NOTAMs'
        }
        response = Faraday.post Configuration::URL, request_params
        File.write(cache_file_path, response.body)
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

    end

    def self.parse_validity_time(text)
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
