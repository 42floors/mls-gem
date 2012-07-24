require 'test_helper'

class TestMLS < ::Test::Unit::TestCase

  def test_API_VERSION
    assert_equal "0.1.0", MLS::API_VERSION
  end

  def test_attr_accessors
    mls = MLS.instance

    assert mls.respond_to?(:url)
    assert mls.respond_to?(:url=)
    assert mls.respond_to?(:api_key)
    assert mls.respond_to?(:auth_key)
    assert mls.respond_to?(:logger)
    assert mls.respond_to?(:connection)
    assert mls.respond_to?(:add_headers)

    assert mls.respond_to?(:put)
    assert mls.respond_to?(:post)
    assert mls.respond_to?(:get)
    assert mls.respond_to?(:delete)

    assert mls.respond_to?(:handle_response)
    assert mls.respond_to?(:ping)
    assert mls.respond_to?(:auth_ping)
    assert mls.respond_to?(:default_logger)
  end

  def test_class_methods
    assert MLS.respond_to?(:parse)
  end
end
