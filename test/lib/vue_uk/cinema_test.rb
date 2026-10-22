require_relative '../../test_helper'

class VueUk::CinemaTest < Minitest::Test
  def setup
    @api_response = FakeApiResponse.new
    VueUk::Cinema.instance_variable_set(:@cinemas_hash, nil)
  end

  def test_new_stores_string_id
    assert_equal '10051', VueUk::Cinema.new(10051).id
  end

  def test_all_returns_uk_cinemas
    with_fakes do
      cinemas = VueUk::Cinema.all

      assert(cinemas.all? { |cinema| cinema.instance_of?(VueUk::Cinema) })
      assert_equal %w(10051 10015), cinemas.map(&:id)
    end
  end

  def test_name_and_full_name
    with_fakes do
      assert_equal 'Accrington', VueUk::Cinema.new(10051).name
      assert_equal 'Vue Birmingham (Star City)', VueUk::Cinema.new(10015).full_name
    end
  end

  def test_brand
    assert_equal 'Vue', VueUk::Cinema.new(10051).brand
  end

  def test_slug
    with_fakes do
      assert_equal 'vue-birmingham-star-city', VueUk::Cinema.new(10015).slug
    end
  end

  def test_url
    with_fakes do
      assert_equal 'https://www.myvue.com/cinema/accrington', VueUk::Cinema.new(10051).url
    end
  end

  def test_adr_from_cinema_page
    expected = {
      street_address:   '1 Example Viaduct',
      extended_address: 'Example Road',
      locality:         'Accrington',
      region:           nil,
      postal_code:      'BB5 0ZZ',
      country_name:     'United Kingdom'
    }

    with_fakes do
      assert_equal expected, VueUk::Cinema.new(10051).adr
      assert_equal 'BB5 0ZZ', VueUk::Cinema.new(10051).postal_code
    end
  end

  def test_adr_with_country_after_postcode
    website = Object.new
    website.define_singleton_method(:cinema) do |_url|
      { 'cinemaAddress' => { 'value' => "2 Example Park\r\nExample Rd, Barrow-in-Furness\r\nLA14 0ZZ, UK" } }
    end

    VueUk::Internal::ApiResponse.stub(:new, @api_response) do
      VueUk::Internal::Website.stub(:new, website) do
        adr = VueUk::Cinema.new(10051).adr

        assert_equal 'LA14 0ZZ', adr[:postal_code]
        assert_equal 'Example Rd, Barrow-in-Furness', adr[:locality]
        assert_equal '2 Example Park', adr[:street_address]
      end
    end
  end

  def test_adr_with_county_before_postcode
    adr = adr_for("1 Example Park\r\nExample Way\r\nColchester\r\nEssex CO4 0ZZ")

    assert_equal 'CO4 0ZZ', adr[:postal_code]
    assert_equal 'Essex', adr[:region]
    assert_equal 'Colchester', adr[:locality]
  end

  def test_adr_ignores_map_coordinates
    adr = adr_for("O2 Example Centre\r\n255 Example Road\r\nLondon\r\n51.548, -0.181")

    assert_nil adr[:postal_code]
    assert_equal 'London', adr[:locality]
    assert_equal '255 Example Road', adr[:extended_address]
  end

  private

  def adr_for(address)
    website = Object.new
    website.define_singleton_method(:cinema) { |_url| { 'cinemaAddress' => { 'value' => address } } }

    VueUk::Internal::ApiResponse.stub(:new, @api_response) do
      VueUk::Internal::Website.stub(:new, website) { VueUk::Cinema.new(10051).adr }
    end
  end

  def with_fakes(&block)
    VueUk::Internal::ApiResponse.stub(:new, @api_response) do
      VueUk::Internal::Website.stub(:new, FakeWebsite.new, &block)
    end
  end
end
