require 'json'

module VfrUtils
  class Cache

    def get(k, &blk)
       return get_files(k, &blk) if VfrUtils.configuration.cache_backend == :files
       raise "Unsupported cache backend: #{VfrUtils.configuration.cache_backend}"
    end

    private

    def get_files(k)
      cache_file_path = "#{VfrUtils.configuration.cache_directory}/#{k}.tmp"
      if File.exists?(cache_file_path)
        if Time.now.to_i - File.ctime(cache_file_path).to_i > VfrUtils.configuration.cache_lifetime
          FileUtils.rm_rf(cache_file_path)
        else
          return JSON.parse(File.read(cache_file_path))
        end
      end
      v = yield
      File.write(cache_file_path, JSON.generate(v))
      v
    end
  end
end
