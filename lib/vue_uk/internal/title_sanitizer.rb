module VueUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [VueUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\s*\(\d{1,2} [A-Z][a-z]+ \d{4}\)/ # screening date
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        COMMON_REPLACE
      end
    end
  end
end
