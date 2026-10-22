require_relative '../../test_helper'

class VueUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil VueUk::VERSION
  end
end
