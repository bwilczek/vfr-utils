### Introduction
This gem provides interface (both programmatic and CLI) to obtain aeronautical data (NOTAM for the start, METAR and TAF soon).

### Installation
```
gem install vfr-utils
```

### NOTAM
```
require 'vfr-utils'

# Configuration (optional)
VfrUtils::NOTAM.configure do |config|

  # seconds to cache NOTAM data in tmp files, default 12h
  config.cache_lifetime = 3600

  # location of tmp files, default #{Dir.tmpdir}/vfr-utils
  config.cache_directory = '/usr/data/cache'
end

# Fetch for multiple aerodromes (ICAO codes)
pp VfrUtils::NOTAM.get [ 'EPWR', 'EPPO', 'LKLB' ]

# Fetch for single aerodrome (ICAO codes)
pp VfrUtils::NOTAM.get_one 'EPWR'
```

### Command Line Interface
```
vfr-utils notam EPWR LKLB
```
