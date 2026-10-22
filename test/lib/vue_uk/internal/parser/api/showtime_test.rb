require_relative '../../../../../test_helper'

class VueUk::Internal::Parser::Api::ShowtimeTest < Minitest::Test
  def test_to_hash
    expected = {
      booking_url: 'https://www.myvue.com/book-tickets/summary/10051/HO1/1',
      dimension: '2d',
      festival: nil,
      film_name: 'From Dusk Till Dawn',
      film_year: 1996,
      language: nil,
      starting_at: Time.utc(2026, 10, 24, 17, 30),
      variant: []
    }

    assert_equal expected, parse
  end

  def test_language_includes_english
    assert_equal 'English', parse(attributes: ['English'])[:language]
  end

  def test_maps_attribute_names_to_variants
    variant = parse(attributes: ['Autism Friendly', 'Big Shorts', 'Laser', 'Single Seat'])[:variant]

    assert_equal %w(autism_friendly kids), variant
  end

  def test_missing_booking_url
    assert_nil parse(booking_url: nil)[:booking_url]
  end

  private

  def parse(attributes: [], booking_url: '/book-tickets/summary/10051/HO1/1')
    session = {
      'bookingUrl' => booking_url,
      'showTimeWithTimeZone' => '2026-10-24T18:30:00+01:00',
      'attributes' => attributes.map { |name| { 'name' => name } }
    }
    film = { 'filmTitle' => 'From Dusk Till Dawn (1996)' }
    VueUk::Internal::Parser::Api::Showtime.new(session, film: film).to_hash
  end
end
