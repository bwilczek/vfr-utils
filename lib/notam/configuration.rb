require 'tmpdir'

module VfrUtils
  module NOTAM
    class Configuration
      attr_accessor :cache_lifetime
      attr_accessor :cache_directory

      URL='https://www.notams.faa.gov/dinsQueryWeb/queryRetrievalMapAction.do'

      def initialize(defaults={})
        @cache_lifetime = defaults[:cache_lifetime] || 86400 # 86400 secs = 12 hours
        @cache_directory = defaults[:cache_directory] || "#{Dir.tmpdir}/vfr-utils"
      end
    end
  end
end
