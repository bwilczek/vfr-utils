require_relative 'version'

module VfrUtils
  module CLI

    ALLOWED_ACTIONS = [
      'metar',
      # 'taf',
      'notam'
    ]

    def self.run(argv)
      return usage if argv.empty?
      action = argv[0].downcase
      params = argv[1..-1]
      return usage unless ALLOWED_ACTIONS.include? action
      send(action.to_sym, params)
      0
    end

    def self.usage
      STDERR.puts "Version: #{VfrUtils::VERSION} Usage: vfr-utils <action> <params>"
      STDERR.puts ""
      STDERR.puts "Allowed actions:"
      ALLOWED_ACTIONS.each { |action| STDERR.puts "  #{action} <space delimited list of ICAO codes>" }
      STDERR.puts ""
      1
    end

    def self.notam(icao_codes)
      require_relative 'notam'
      require_relative 'formatter/notam'
      VfrUtils::Formatter::NOTAM.pretty_display(VfrUtils::NOTAM.get(icao_codes))
    end

    def self.metar(icao_codes)
      require_relative 'metar'
      require_relative 'formatter/metar'
      VfrUtils::Formatter::METAR.pretty_display(VfrUtils::METAR.get(icao_codes))
    end

  end
end
