# Read hand-written fixtures from disk. They follow the shape in
# api_shapes.rb; they are never recorded output from myvue.com.
module FixturesHelper
  private

  def cinemas_json
    read_fixture('api/cinemas.json')
  end

  def films_json(cinema_id)
    read_fixture("api/films-#{cinema_id}.json")
  end

  def cinema_page_html(cinema_id)
    read_fixture("website/cinema-#{cinema_id}.html")
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
