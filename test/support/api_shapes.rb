require 'time'

# The parts of Vue responses the gem reads. Checked against the hand-written
# fixtures and, in the live suite, against real responses held only in memory.
module ApiShapes
  private

  def assert_cinemas_shape(data)
    cinemas = data.fetch('result').flat_map { |group| group.fetch('cinemas') }
    refute_empty cinemas
    cinemas.each do |cinema|
      assert_match(/\A\d+\z/, cinema.fetch('cinemaId'))
      assert_kind_of String, cinema.fetch('cinemaName')
      assert_kind_of String, cinema.fetch('venueCurrency')
      assert_match(%r{\Ahttps://www\.myvue\.com/cinema/[a-z0-9-]+/whats-on\z}, cinema.fetch('whatsOnUrl'))
    end
  end

  def assert_films_shape(data)
    films = data.fetch('result')
    refute_empty films
    films.each do |film|
      assert_kind_of String, film.fetch('filmTitle')
      film.fetch('showingGroups').each do |group|
        assert_match(/\A\d{4}-\d{2}-\d{2}T/, group.fetch('date'))
        group.fetch('sessions').each do |session|
          assert_kind_of Time, Time.iso8601(session.fetch('showTimeWithTimeZone'))
          assert_match(%r{\A/}, session.fetch('bookingUrl'))
          session.fetch('attributes').each { |attribute| assert_kind_of String, attribute.fetch('name') }
        end
      end
    end
  end

  def assert_cinema_page_shape(cinema)
    assert_kind_of String, cinema.fetch('cinemaAddress').fetch('value')
  end
end
