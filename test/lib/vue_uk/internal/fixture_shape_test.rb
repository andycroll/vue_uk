require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_cinemas_fixture_matches_shape
    assert_cinemas_shape(JSON.parse(cinemas_json))
  end

  def test_films_fixture_matches_shape
    assert_films_shape(JSON.parse(films_json('10051')))
  end

  def test_cinema_page_fixture_matches_shape
    assert_cinema_page_shape(FakeWebsite.new.cinema('https://www.myvue.com/cinema/accrington/whats-on'))
  end
end
