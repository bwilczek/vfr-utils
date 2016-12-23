module VfrUtils
  class Cache

    def initialize(config)
      @config = config
    end

    def get(k, &blk)
       return get_files(k, &blk) if config.cache_backend == :files
       raise "Unsupported cache backend: #{config.cache_backend}"
    end

    private

    def config
      @config
    end

    def get_files(k)
      cache_file_path = "#{config.cache_directory}/#{k}.tmp"
      if File.exists?(cache_file_path)
        if Time.now.to_i - File.ctime(cache_file_path).to_i > config.cache_lifetime
          FileUtils.rm_rf(cache_file_path)
        else
          return Marshal.load(File.read(cache_file_path))
        end
      end
      v = yield
      File.write(cache_file_path, Marshal.dump(v))
      v
    end
  end
end
