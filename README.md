### Introduction
This gem provides interface (both programmatic and CLI) to obtain aeronautical data (NOTAM, METAR and TAF).

### Installation
```
gem install vfr_utils
```

### Usage examples
```
require 'vfr_utils'

# Configuration (optional)
VfrUtils.configure do |config|

  # global settings for all services
  config.global {

    # seconds to cache data, default is 15 minutes
    config.cache_lifetime = 900

    # location of tmp files, default #{Dir.tmpdir}/vfr_utils
    config.cache_directory = '/usr/data/cache'
  }

  # those can be overwritten for each service:
  config.notam.cache_lifetime = 3600 # cache NOTAMS for 12h
  config.taf.cache_backend = :redis
  config.taf.redis_url = 'redis://localhost:6379'
  config.metar.cache_directory = '/usr/data/cache/weather'
end

# Fetch NOTAMs for multiple aerodromes (ICAO codes)
pp VfrUtils::NOTAM.get [ 'EPWR', 'EPPO', 'LKLB' ]

# Fetch TAF for single aerodrome (ICAO codes)
pp VfrUtils::TAF.get_one 'EPWR'

# Fetch METAR for single aerodrome (ICAO codes)
pp VfrUtils::METAR.get_one 'EPPO'
```

### Command Line Interface
```
vfr_utils notam EPWR LKLB
vfr_utils taf EPWR
vfr_utils metar EPWR LKLB KJFK
```
