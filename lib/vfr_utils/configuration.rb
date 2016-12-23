require 'tmpdir'

module VfrUtils
  class Configuration
    DEFAULTS = {
      cache_lifetime: 900, # 900 secs = 15 minutes
      cache_directory: "#{Dir.tmpdir}/vfr-utils",
      cache_backend: :files,
      redis_url: nil,
    }
    attr_accessor :cache_lifetime
    attr_accessor :cache_directory
    attr_accessor :cache_backend
    attr_accessor :redis_url

    def initialize(defaults=DEFAULTS)
      @cache_lifetime = defaults[:cache_lifetime] || DEFAULTS[:cache_lifetime]
      @cache_directory = defaults[:cache_directory] || DEFAULTS[:cache_directory]
      @cache_backend = defaults[:cache_backend] || DEFAULTS[:cache_backend]
      @redis_url = defaults[:redis_url] || DEFAULTS[:redis_url]
      apply
    end

    def apply
      FileUtils.mkdir_p @cache_directory if @cache_backend == :files
    end

  end
end
