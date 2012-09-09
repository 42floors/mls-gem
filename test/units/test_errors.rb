require 'test_helper'

class TestErrors < ::Test::Unit::TestCase
  
  def test_exception
    assert defined?(MLS::Exception)
  end

  def test_bad_request
    assert defined?(MLS::Exception::BadRequest)
  end

  def test_unauthorized
    assert defined?(MLS::Exception::Unauthorized)
  end

  def test_not_found
    assert defined?(MLS::Exception::NotFound)
  end

  def test_api_version_unsupported
    assert defined?(MLS::Exception::ApiVersionUnsupported)
  end
  
  def test_record_invalide
    assert defined?(MLS::Exception::RecordInvalid)
  end
  
  def test_service_unavailable
    assert defined?(MLS::Exception::ServiceUnavailable)
  end
end
