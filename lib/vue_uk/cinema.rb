module VueUk
  # The object representing a cinema on the Vue website
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the Vue id of the cinema, e.g. '10051'

    # UK postcode, the last line of an address
    POSTCODE = /\A[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}\z/i.freeze

    # A county and postcode on one line, e.g. 'Essex CO4 5UP'
    REGION_AND_POSTCODE = /\A(.+?)\s+([A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2})\z/i.freeze

    # Map coordinates, as on each cinema page and in place of a postcode in
    # some addresses
    COORDINATES = /\A-?\d+(\.\d+)?,\s*-?\d+(\.\d+)?\z/.freeze

    # Constructor
    # @param [Integer, String] id the cinema id of the format 10051/'10051'
    # @return [VueUk::Cinema]
    def initialize(id)
      @id = id.to_s
    end

    # Return basic cinema information for all UK cinemas
    # @return [Array<VueUk::Cinema>]
    # @example
    #   VueUk::Cinema.all
    #   #=> [<VueUk::Cinema>, <VueUk::Cinema>, ...]
    def self.all
      cinemas_hash.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema, read from its page on the Vue website
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = VueUk::Cinema.new(10051)
    #   cinema.adr
    #   #=> {
    #         street_address:   'The Viaduct',
    #         extended_address: 'Hyndburn Road',
    #         locality:         'Accrington',
    #         region:           nil,
    #         postal_code:      'BB5 1QF',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      lines = address_lines
      if lines.last&.match?(POSTCODE)
        postal_code = lines.pop
      elsif (match = lines.last&.match(REGION_AND_POSTCODE))
        lines.pop
        region, postal_code = match.captures
      end
      street_address = lines.shift
      locality = lines.pop
      {
        street_address:   street_address,
        extended_address: lines.empty? ? nil : lines.join(', '),
        locality:         locality,
        region:           region,
        postal_code:      postal_code,
        country_name:     'United Kingdom'.freeze
      }
    end

    # Brand of the cinema
    # @return [String] which will always be 'Vue'
    def brand
      'Vue'.freeze
    end

    # Latitude of the cinema, read from its page on the Vue website
    # @return [Float, nil] decimal degrees, or nil when unknown
    # @example
    #   VueUk::Cinema.new(10051).latitude
    #   #=> 53.754874975913864
    def latitude
      coordinates&.first
    end

    # Longitude of the cinema, read from its page on the Vue website
    # @return [Float, nil] decimal degrees, or nil when unknown
    # @example
    #   VueUk::Cinema.new(10051).longitude
    #   #=> -2.369161692538972
    def longitude
      coordinates&.last
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   VueUk::Cinema.new(10051).name
    #   #=> 'Accrington'
    def name
      cinema_hash['cinemaName'].to_s
    end

    # The url of the cinema on the Vue website
    # @return [String]
    def url
      cinema_hash['whatsOnUrl'].to_s.delete_suffix('/whats-on')
    end

    # @api private
    # Leaves out Vue's euro-priced cinemas outside the UK.
    def self.cinemas_hash
      @cinemas_hash ||= VueUk::Internal::ApiResponse.new.cinemas
                                                    .select { |cinema| cinema['venueCurrency'] == 'GBP' }
                                                    .to_h { |cinema| [cinema.fetch('cinemaId'), cinema] }
    end
    private_class_method :cinemas_hash

    private

    def address_lines
      page.dig('cinemaAddress', 'value').to_s.split(/\r?\n/)
           .map { |line| line.strip.sub(/,\s*(UK|United Kingdom)\z/i, '') }
           .reject { |line| line.empty? || line.match?(COORDINATES) }
    end

    def cinema_hash
      @cinema_hash ||= self.class.send(:cinemas_hash).fetch(id, {})
    end

    # 0, 0 marks a cinema whose position was never set
    def coordinates
      value = page.dig('cinemaLocationCoordinates', 'value').to_s.strip
      if value.match?(COORDINATES)
        pair = value.split(',').map(&:to_f)
        pair if pair.any?(&:nonzero?)
      end
    end

    def page
      @page ||= VueUk::Internal::Website.new.cinema(cinema_hash.fetch('whatsOnUrl'))
    end
  end
end
