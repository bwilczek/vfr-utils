require 'tmpdir'

module VfrUtils
  class Configuration
    attr_accessor :cache_lifetime
    attr_accessor :cache_directory
    attr_accessor :cache_backend
    attr_accessor :redis_url

    def initialize(defaults={})
      @cache_lifetime = defaults[:cache_lifetime] || 86400 # 86400 secs = 12 hours
      @cache_directory = defaults[:cache_directory] || "#{Dir.tmpdir}/vfr-utils"
      @cache_backend = defaults[:cache_backend] || :files
      @redis_url = defaults[:redis_url] || nil
      apply
    end

    def apply
      FileUtils.mkdir_p @cache_directory
    end

  end
end
