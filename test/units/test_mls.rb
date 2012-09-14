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

  test 'handle_response raises BadRequest on 400' do
    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["400", "BadRequest"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception::BadRequest){ MLS.handle_response(response) }
  end
    
  test 'handle_response raises Unauthorized on 401' do
    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["401", "Unauthorized"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception::Unauthorized){ MLS.handle_response(response) }
  end
    
  test 'handle_response raises NotFound on 404' do
    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["404", "Not Found"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception::NotFound){ MLS.handle_response(response) }
  end

  test 'handle_response raises NotFound on 410' do
    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["410", "Not Found"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception::NotFound){ MLS.handle_response(response) }
  end

  test 'handle_response raises ApiVersionUnsupported on 422' do
    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["422", "Unsupported"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception::ApiVersionUnsupported){ MLS.handle_response(response) }
  end
  
  test 'handle_response raises ServiceUnavailable on 503' do
    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["503", "Error"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception::ServiceUnavailable){ MLS.handle_response(response) }
  end
  
  test 'handle_response raises Exception on 350, 450, & 550' do
    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["350", "Error"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception){ MLS.handle_response(response) }

    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["450", "Error"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception){ MLS.handle_response(response) }

    FakeWeb.register_uri(:get, "http://mls.test/test", :status => ["550", "Error"])
    response = Net::HTTP.get_response(URI.parse("http://mls.test/test"))
    assert_raises(MLS::Exception){ MLS.handle_response(response) }
  end
  
end