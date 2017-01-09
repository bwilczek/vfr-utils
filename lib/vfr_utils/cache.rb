module VfrUtils
  class Cache

    def initialize(config)
      @config = config
      init_redis
    end

    def get(k, &blk)
       return get_files(k, &blk) if config.cache_backend == :files
       return get_redis(k, &blk) if config.cache_backend == :redis
       raise "Unsupported cache backend: #{config.cache_backend}"
    end

    private

    def config
      @config
    end

    def init_redis
      return unless config.cache_backend == :redis
      return unless @redis.nil?
      @redis = Redis.new(url: config.redis_url)
    end

    def get_files(k)
      cache_file_path = "#{config.cache_directory}/#{k}.tmp"
      if File.exists?(cache_file_path)
        if Time.now.to_i - File.ctime(cache_file_path).to_i > config.cache_lifetime
          FileUtils.rm_rf(cache_file_path)
        else
          return Marshal.load(File.binread(cache_file_path))
        end
      end
      v = yield
      File.binwrite(cache_file_path, Marshal.dump(v))
      v
    end

    def get_redis(k)
      init_redis
      v = @redis.get(k)
      return Marshal.load(v) unless v.nil?
      v = yield
      @redis.setex(k, config.cache_lifetime, Marshal.dump(v))
      v
    end
  end
end
