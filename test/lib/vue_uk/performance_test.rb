require_relative '../../test_helper'

class VueUk::PerformanceTest < Minitest::Test
  DATE = Date.new(2026, 10, 24)

  def setup
    @api_response = FakeApiResponse.new
    VueUk::Cinema.instance_variable_set(:@cinemas_hash, nil)
  end

  def test_at_returns_performances_on_the_requested_date_only
    performances = performances_at(10051)

    assert(performances.all? { |p| p.instance_of?(VueUk::Performance) })
    assert_equal 5, performances.count
  end

  def test_at_accepts_string_id
    assert_equal 5, performances_at('10051').count
  end

  def test_at_sets_cinema_details
    performances = performances_at(10051)

    assert_equal ['10051'], performances.map(&:cinema_id).uniq
    assert_equal ['Accrington'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    performance = performances_at(10051).first

    assert_equal 'The Example Film', performance.film_name
    assert_equal Time.utc(2026, 10, 24, 9, 30), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal 'English', performance.language
    assert_equal %w(audio_described), performance.variant
    assert_equal 'https://www.myvue.com/book-tickets/summary/10051/HO1/1001', performance.booking_url
  end

  def test_at_parses_3d
    assert_equal '3d', performances_at(10051)[1].dimension
  end

  def test_at_moves_year_and_language_from_title
    performance = performances_at(10051)[2]

    assert_equal 'Imaginary Picture', performance.film_name
    assert_equal 2026, performance.film_year
    assert_equal 'Tamil', performance.language
    assert performance.subtitled?
  end

  def test_at_strips_screening_date
    performance = performances_at(10051)[3]

    assert_equal 'Mystery Screening', performance.film_name
    assert_equal %w(kids), performance.variant
  end

  def test_at_moves_festival_from_title
    performance = performances_at(10051)[4]

    assert_equal 'Made Up Matinee', performance.film_name
    assert_equal Cinebase::Festival.new(name: 'CFF', year: 2026), performance.festival
    assert_equal %w(arts), performance.variant
  end

  def test_at_keeps_after_midnight_on_next_utc_day
    assert_equal Time.utc(2026, 10, 24, 23, 15), performances_at(10051).last.starting_at
  end

  def test_at_filters_one_request_to_the_date_range
    performances = with_fake_api { VueUk::Performance.at(10051, from: DATE, to: DATE + 1) }

    assert_equal 6, performances.count
    assert_includes performances.map(&:starting_at), Time.utc(2026, 10, 25, 10, 30)
    assert_equal 1, @api_response.requests
  end

  def test_at_rejects_range_ending_before_start
    assert_raises(ArgumentError) { VueUk::Performance.at(10051, from: DATE, to: DATE - 1) }
  end

  def test_new_sets_defaults
    performance = VueUk::Performance.new(
      film_name: 'Carol', cinema_id: '10051', cinema_name: 'Accrington',
      starting_at: Time.utc(2013, 9, 12, 11, 0)
    )

    assert_nil performance.booking_url
    assert_equal '2d', performance.dimension
    assert_nil performance.festival
    assert_nil performance.film_year
    assert_nil performance.language
    refute performance.subtitled?
    assert_equal [], performance.variant
  end

  private

  def performances_at(cinema_id)
    with_fake_api { VueUk::Performance.at(cinema_id, from: DATE, to: DATE) }
  end

  def with_fake_api(&block)
    VueUk::Internal::ApiResponse.stub(:new, @api_response, &block)
  end
end
