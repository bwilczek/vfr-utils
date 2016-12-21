require 'pp'

module VfrUtils
  module Formatter
    module METAR
      def self.pretty_display(data)
        pp data
      end
    end
  end
end
