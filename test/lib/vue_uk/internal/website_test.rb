require_relative '../../../test_helper'

class VueUk::Internal::WebsiteTest < Minitest::Test
  include FixturesHelper

  URL = 'https://www.myvue.com/cinema/accrington/whats-on'.freeze

  def test_cinema_reads_page_data
    stub_request(:get, URL).to_return(status: 200, body: cinema_page_html('10051'))

    cinema = VueUk::Internal::Website.new.cinema(URL)

    assert_equal "1 Example Viaduct\r\nExample Road\r\nAccrington\r\nBB5 0ZZ       ",
                 cinema.dig('cinemaAddress', 'value')
  end

  def test_cinema_without_page_data_is_empty
    stub_request(:get, URL).to_return(status: 200, body: '<script id="__NEXT_DATA__">{}</script>')

    assert_equal({}, VueUk::Internal::Website.new.cinema(URL))
  end
end
