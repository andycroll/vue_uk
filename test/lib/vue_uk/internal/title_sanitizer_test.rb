require_relative '../../../test_helper'

class VueUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_removes_screening_date
    assert_sanitized 'Mystery Screening', 'Mystery Screening (23 October 2026)'
  end

  def test_removes_language_version
    assert_sanitized 'Jailer 2', 'Jailer 2 (Tamil)'
  end

  def test_removes_film_year
    assert_sanitized 'Street Fighter', 'Street Fighter (2026)'
  end

  def test_keeps_titles_with_their_own_subtitles
    [
      'Ghosts: The Possession of Button House',
      'Spider-Man: Brand New Day',
      "We're Going on a Bear Hunt + The Tiger Who Came to Tea",
      'Blade Runner 2049'
    ].each { |title| assert_sanitized title, title }
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, VueUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
