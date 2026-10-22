module VueUk
  # A single screening of a film on the Vue website
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String] the booking URL on the cinema website
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year from the film's title
    #   @option options [String] :language (nil) audio language, e.g. 'English'
    #   @option options [Time] :starting_at listed start time of the performance

    # Performances within an inclusive range of showing dates, from one request
    # for all of the cinema's advertised dates.
    # @param [Integer, String] cinema_id id of the cinema
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<VueUk::Performance>]
    def self.at(
      cinema_id,
      from: TZInfo::Timezone.get('Europe/London').now.to_date,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      VueUk::Internal::ApiResponse.new.films(cinema.id).flat_map do |film|
        sessions_between(film, from, to).map do |session|
          showtime = VueUk::Internal::Parser::Api::Showtime.new(session, film: film)
          new(showtime.to_hash.merge(cinema_id: cinema.id, cinema_name: cinema.name))
        end
      end
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (arts, audio_described, kids, subtitled ...)
    #   @return <Array[String]>

    # private

    def self.sessions_between(film, from, to)
      film.fetch('showingGroups', [])
          .select { |group| (from..to).cover?(Date.iso8601(group.fetch('date')[0, 10])) }
          .flat_map { |group| group.fetch('sessions', []) }
    end
    private_class_method :sessions_between
  end
end
