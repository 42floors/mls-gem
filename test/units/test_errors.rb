require 'test_helper'

class TestErrors < ::Test::Unit::TestCase
  
  def test_exception
    assert defined?(MLS::Exception)
  end

  def test_bad_request
    assert defined?(MLS::BadRequest)
  end

  def test_unauthorized
    assert defined?(MLS::Unauthorized)
  end

  def test_not_found
    assert defined?(MLS::NotFound)
  end

  def test_api_version_unsupported
    assert defined?(MLS::ApiVersionUnsupported)
  end
end
