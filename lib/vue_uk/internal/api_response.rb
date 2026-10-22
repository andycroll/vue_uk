# frozen_string_literal: true

require "json"

module VueUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Fetches cinema and showing data from the API behind myvue.com
    class ApiResponse
      include Http

      BASE_URL = "https://www.myvue.com/api/microservice/"
      # The query the website itself sends; embargo level 3 is public listings
      FILM_QUERY = {
        "minEmbargoLevel" => 3, "includesSession" => true, "includeSessionAttributes" => true
      }.freeze

      # @return [Array<Hash>] cinemas
      def cinemas
        fetch("showings/cinemas").fetch("result").flat_map { |group| group.fetch("cinemas") }
      end

      # @param [String] cinema_id e.g. '10051'
      # @return [Array<Hash>] films with their sessions on every advertised date
      def films(cinema_id)
        fetch("showings/cinemas/#{cinema_id}/films", FILM_QUERY).fetch("result")
      end

      private

      # Uncached responses need the guest session the website starts for
      # every visitor; start a fresh one once if it is rejected.
      def fetch(path, query = {})
        url = BASE_URL + path
        url += "?#{URI.encode_www_form(query)}" unless query.empty?
        retried = false
        begin
          @session ||= post_for_cookies("#{BASE_URL}auth/token", accept: "application/json")
          JSON.parse(get(url, accept: "application/json", cookie: @session))
        rescue Unauthorized
          raise if retried

          retried = true
          @session = nil
          retry
        end
      end
    end
  end
end
