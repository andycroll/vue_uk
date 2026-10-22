require_relative 'fixtures_helper'

class FakeApiResponse
  include FixturesHelper

  attr_reader :requests

  def initialize
    @requests = 0
  end

  def cinemas
    JSON.parse(cinemas_json).fetch('result').flat_map { |group| group.fetch('cinemas') }
  end

  def films(cinema_id)
    @requests += 1
    JSON.parse(films_json(cinema_id)).fetch('result')
  end
end

class FakeWebsite
  include FixturesHelper

  def cinema(url)
    id = url[%r{/cinema/accrington/}] ? '10051' : (raise "No fixture for #{url}")
    html = cinema_page_html(id)
    JSON.parse(html[%r{<script id="__NEXT_DATA__"[^>]*>(.*?)</script>}m, 1])
        .dig('props', 'pageProps', 'layoutData', 'sitecore', 'context', 'cinema')
  end
end
