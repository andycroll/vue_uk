# frozen_string_literal: true

require "json"

module VueUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads cinema details the API doesn't give from a cinema's page data
    class Website
      include Http

      # @param [String] url a cinema's what's on page
      # @return [Hash] the page's cinema details, e.g. its cinemaAddress
      def cinema(url)
        html = get(url, accept: "text/html")
        script = html[%r{<script id="__NEXT_DATA__"[^>]*>(.*?)</script>}m, 1].to_s
        JSON.parse(script).dig("props", "pageProps", "layoutData", "sitecore", "context", "cinema") || {}
      end
    end
  end
end
