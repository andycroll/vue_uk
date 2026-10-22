# frozen_string_literal: true

require "time"

module VueUk
  # @api private
  module Internal
    module Parser
      module Api
        # Parses a single Vue session into performance attributes
        class Showtime
          BOOKING_HOST = "https://www.myvue.com"

          # Vue attribute names
          VARIANTS = {
            "Audio Description (AD)" => "audio_described",
            "Autism Friendly" => "autism_friendly",
            "Big Screen Events" => "arts",
            "Big Screen Music" => "arts",
            "Big Screen Musicals" => "arts",
            "Big Shorts" => "kids",
            "Event" => "arts",
            "Mighty Mornings" => "kids",
            "Open Captioned" => "subtitled"
          }.freeze

          # Vue tags English audio too, unlike the other chains
          LANGUAGES = (Cinebase::TitleSanitizer::LANGUAGES + ["English"]).freeze

          # @param [Hash] session one session
          # @param [Hash] film the film the session shows
          def initialize(session, film:)
            @session = session
            @film = film
          end

          # @return [Hash] options for VueUk::Performance.new
          def to_hash
            {
              booking_url: booking_url,
              dimension: attribute_names.any? { |name| name.match?(/\b3D\b/i) } ? "3d" : "2d",
              festival: Cinebase::Festival.from_title(title, year: starting_at.year),
              film_name: TitleSanitizer.new(title).sanitized,
              film_year: Cinebase::TitleSanitizer.film_year(title),
              language: attribute_names.find { |name| LANGUAGES.include?(name) },
              starting_at: starting_at,
              variant: attribute_names.filter_map { |name| VARIANTS[name] }.uniq
            }
          end

          private

          def attribute_names
            @attribute_names ||= @session.fetch("attributes", []).map { |attribute| attribute["name"].to_s.strip }
          end

          def booking_url
            path = @session["bookingUrl"]
            URI.join(BOOKING_HOST, path).to_s if path
          end

          def starting_at
            Time.iso8601(@session.fetch("showTimeWithTimeZone")).utc
          end

          def title
            @film.fetch("filmTitle")
          end
        end
      end
    end
  end
end
