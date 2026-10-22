# frozen_string_literal: true

require "net/http"

module VueUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Requests to myvue.com
    module Http
      class Unauthorized < StandardError; end

      private

      def get(url, accept:, cookie: nil)
        request = Net::HTTP::Get.new(URI(url))
        request["Cookie"] = cookie if cookie
        perform(request, accept: accept).body
      end

      # @return [String] the response's cookies as a Cookie header value
      def post_for_cookies(url, accept:)
        response = perform(Net::HTTP::Post.new(URI(url)), accept: accept)
        response.get_fields("Set-Cookie").to_a.map { |cookie| cookie.split(";").first }.join("; ")
      end

      def perform(request, accept:)
        request["Accept"] = accept
        uri = request.uri
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                                                       open_timeout: 10, read_timeout: 30) do |http|
          http.request(request)
        end
        # Omit response bodies from errors, and never follow redirects.
        raise Unauthorized, "Vue HTTP error 401" if response.is_a?(Net::HTTPUnauthorized)
        raise "Vue HTTP error #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        response
      end
    end
  end
end
