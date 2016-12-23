require 'pp'

module VfrUtils
  module Formatter
    module NOTAM
      def self.pretty_display(notams)
        notams.each_pair do |icao_code, notams_for_aerodrome|
          puts "=================================================="
          puts "=====================  #{icao_code}  ====================="
          notams_for_aerodrome.each do |notam_data|
            puts "=================================================="
            puts "Signature: #{notam_data[:signature]}" if notam_data[:signature]
            puts "Valid from: #{notam_data[:valid_from].strftime("%F %H:%M (%A)")}" if notam_data[:valid_from]
            puts "Valid to:   #{notam_data[:valid_to].strftime("%F %H:%M (%A)")}" if notam_data[:valid_to]
            puts ""
            puts notam_data[:message]
            puts ""
            puts "Created at #{notam_data[:created_at].strftime("%F %H:%M")} by #{notam_data[:source]}" if notam_data[:created_at]
            puts "" if notam_data[:created_at]
          end
        end
      end
    end
  end
end
