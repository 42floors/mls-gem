require 'test_helper'

class TestPhoto < ::Test::Unit::TestCase

  def test_instance_methods
    photo = MLS::Photo.new({})

    assert photo.respond_to?(:url)
  end

end
