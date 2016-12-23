require 'pp'

module VfrUtils
  module Formatter
    module Weather
      def self.pretty_display(data)
        data.each_pair do |icao_code, data_for_aerodrome|
          puts ""
          #puts "=================================================="
          puts "=====================  #{icao_code}  ====================="
          puts data_for_aerodrome[:data]
          puts "=================================================="
        end
      end
    end
  end
end
