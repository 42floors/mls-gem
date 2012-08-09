require 'test_helper'

class TestFlyer < ::Test::Unit::TestCase


  def test_create_flyer
    flyer = MLS::Flyer.create(File.new('test/fixtures/flyer.pdf'))
    assert flyer.id
  end

end