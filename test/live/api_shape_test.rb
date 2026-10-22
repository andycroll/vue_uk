require_relative 'live_helper'

class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_cinemas_are_readable
    assert_cinemas_shape('result' => [{ 'cinemas' => VueUk::Internal::ApiResponse.new.cinemas }])
  end

  def test_films_are_readable
    assert_films_shape('result' => VueUk::Internal::ApiResponse.new.films('10051'))
  end

  def test_cinema_page_is_readable
    assert_cinema_page_shape(VueUk::Internal::Website.new.cinema('https://www.myvue.com/cinema/accrington/whats-on'))
  end
end
