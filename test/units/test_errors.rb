require 'test_helper'

class TestErrors < ::Test::Unit::TestCase
  
  def test_exception
    assert defined?(MLSGem::Exception)
  end

  def test_bad_request
    assert defined?(MLSGem::Exception::BadRequest)
  end

  def test_unauthorized
    assert defined?(MLSGem::Exception::Unauthorized)
  end

  def test_not_found
    assert defined?(MLSGem::Exception::NotFound)
  end

  def test_api_version_unsupported
    assert defined?(MLSGem::Exception::ApiVersionUnsupported)
  end
  
  def test_record_invalide
    assert defined?(MLSGem::Exception::RecordInvalid)
  end
  
  def test_service_unavailable
    assert defined?(MLSGem::Exception::ServiceUnavailable)
  end
end
