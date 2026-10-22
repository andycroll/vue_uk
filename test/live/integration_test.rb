require_relative 'live_helper'

class LiveCinemaTest < Minitest::Test
  def test_all_returns_cinemas
    cinemas = VueUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(VueUk::Cinema) })
    assert_operator cinemas.size, :>, 70
    assert_equal 'Accrington', cinemas.detect { |cinema| cinema.id == '10051' }.name
  end

  def test_address_has_a_postcode
    refute_empty VueUk::Cinema.new(10051).postal_code
  end
end

class LivePerformanceTest < Minitest::Test
  def test_at_returns_performances
    tomorrow = Date.today + 1
    performances = VueUk::Performance.at(10051, from: tomorrow, to: tomorrow)

    assert(performances.all? { |p| p.instance_of?(VueUk::Performance) })
    assert_operator performances.count, :>, 5
  end
end
