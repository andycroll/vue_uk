require_relative '../../../test_helper'

class VueUk::Internal::ApiResponseTest < Minitest::Test
  include FixturesHelper

  BASE_URL = 'https://www.myvue.com/api/microservice'.freeze
  FILMS_QUERY = { 'minEmbargoLevel' => '3', 'includesSession' => 'true', 'includeSessionAttributes' => 'true' }.freeze

  def setup
    @session = stub_request(:post, "#{BASE_URL}/auth/token")
               .to_return(status: 200, body: '{}', headers: { 'Set-Cookie' => ['accessToken=abc; HttpOnly; Path=/', 'refreshToken=def; HttpOnly; Path=/'] })
  end

  def test_cinemas_sends_guest_session_cookies
    stub_request(:get, "#{BASE_URL}/showings/cinemas")
      .with(headers: { 'Accept' => 'application/json', 'Cookie' => 'accessToken=abc; refreshToken=def' })
      .to_return(status: 200, body: cinemas_json)

    assert_equal %w(10051 10015 90001), api.cinemas.map { |cinema| cinema['cinemaId'] }
  end

  def test_films_for_all_dates
    stub_request(:get, "#{BASE_URL}/showings/cinemas/10051/films")
      .with(query: FILMS_QUERY)
      .to_return(status: 200, body: films_json('10051'))

    assert_equal 'The Example Film', api.films('10051').first['filmTitle']
  end

  def test_reuses_one_session
    stub_request(:get, "#{BASE_URL}/showings/cinemas").to_return(status: 200, body: cinemas_json)
    client = api

    2.times { client.cinemas }

    assert_requested @session, times: 1
  end

  def test_starts_a_fresh_session_once_when_rejected
    stub_request(:get, "#{BASE_URL}/showings/cinemas")
      .to_return({ status: 401 }, { status: 200, body: cinemas_json })

    assert_equal 3, api.cinemas.size
    assert_requested @session, times: 2
  end

  def test_raises_when_a_fresh_session_is_rejected_too
    stub_request(:get, "#{BASE_URL}/showings/cinemas").to_return(status: 401, body: 'secret')

    error = assert_raises(VueUk::Internal::Http::Unauthorized) { api.cinemas }

    assert_equal 'Vue HTTP error 401', error.message
  end

  def test_other_errors_omit_body
    stub_request(:get, "#{BASE_URL}/showings/cinemas").to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { api.cinemas }

    assert_equal 'Vue HTTP error 500', error.message
  end

  private

  def api
    VueUk::Internal::ApiResponse.new
  end
end
