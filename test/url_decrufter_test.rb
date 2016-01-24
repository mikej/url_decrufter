require 'minitest_helper'

class UrlDecrufterTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::UrlDecrufter::VERSION
  end

  def test_it_returns_cruft_free_url_unmodified
    assert_equal "http://www.google.co.uk/", UrlDecrufter::decruft("http://www.google.co.uk/")
  end
end
