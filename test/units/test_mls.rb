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
  
  # MLS.post =================================================================
      
  test '#post' do
    FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post')
    response = MLS.post('/test')
    assert_equal 'post', response.body
  end
  
  test '#post with a body' do
    FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post')
    response = MLS.post('/test', :key => 'value')
    
    assert_equal '{"key":"value"}', FakeWeb.last_request.body    
  end
  
  test '#post to 404 raises MLS::Exception::NotFound' do
    FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post', :status => ['404', ''])
    
    assert_raises(MLS::Exception::NotFound) { MLS.post('/test') }
  end
  
  test '#post to 404 doesnt raise NotFound if in valid_response_codes' do
    assert_nothing_raised {
      FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post', :status => ['404', ''])
      MLS.post('/test', nil, 404)

      FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post', :status => ['404', ''])
      MLS.post('/test', nil, 400..499)
      
      FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post', :status => ['404', ''])
      MLS.post('/test', nil, 300..399, 404)
      
      FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post', :status => ['404', ''])
      MLS.post('/test', nil, 404, 300..399)
      
      FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post', :status => ['404', ''])
      MLS.post('/test', nil, [300..399, 404])
    }
  end
  
  test '#post with block' do
    FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post')
    MLS.post('/test') do |response|
      assert_equal 'post', response.body
    end

    # make sure block is not called when not in valid_response_codes
    FakeWeb.register_uri(:post, "#{MLS_HOST}/test", :body => 'post', :status => ['401', ''])
    assert_raises(MLS::Exception::Unauthorized) {
      MLS.post('/test') do |response|
        raise MLS::Exception, 'Should not get here'
      end
    }
  end
  
  # MLS.delete ================================================================
      
  test '#delete' do
    FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete')
    response = MLS.delete('/test')
    assert_equal 'delete', response.body
  end
  
  test '#delete with a body' do
    FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete')
    response = MLS.delete('/test', :key => 'value')
    
    assert_equal '{"key":"value"}', FakeWeb.last_request.body    
  end
  
  test '#delete to 404 raises MLS::Exception::NotFound' do
    FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete', :status => ['404', ''])
    
    assert_raises(MLS::Exception::NotFound) { MLS.delete('/test') }
  end
  
  test '#delete to 404 doesnt raise NotFound if in valid_response_codes' do
    assert_nothing_raised {
      FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLS.delete('/test', nil, 404)

      FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLS.delete('/test', nil, 400..499)
      
      FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLS.delete('/test', nil, 300..399, 404)
      
      FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLS.delete('/test', nil, 404, 300..399)
      
      FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLS.delete('/test', nil, [300..399, 404])
    }
  end
  
  test '#delete with block' do
    FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete')
    MLS.delete('/test') do |response|
      assert_equal 'delete', response.body
    end

    # make sure block is not called when not in valid_response_codes
    FakeWeb.register_uri(:delete, "#{MLS_HOST}/test", :body => 'delete', :status => ['401', ''])
    assert_raises(MLS::Exception::Unauthorized) {
      MLS.delete('/test') do |response|
        raise MLS::Exception, 'Should not get here'
      end
    }
  end
  
  # MLS.handle_response ======================================================
  
  test 'handle_response raises BadRequest on 400' do
    response = mock_response(:get, 400)
    assert_raises(MLS::Exception::BadRequest) { MLS.handle_response(response) }
  end
    
  test 'handle_response raises Unauthorized on 401' do
    response = mock_response(:get, 401)
    assert_raises(MLS::Exception::Unauthorized) { MLS.handle_response(response) }
  end
    
  test 'handle_response raises NotFound on 404' do
    response = mock_response(:get, 404)
    assert_raises(MLS::Exception::NotFound) { MLS.handle_response(response) }
  end

  test 'handle_response raises NotFound on 410' do
    response = mock_response(:get, 410)
    assert_raises(MLS::Exception::NotFound) { MLS.handle_response(response) }
  end

  test 'handle_response raises ApiVersionUnsupported on 422' do
    response = mock_response(:get, 422)
    assert_raises(MLS::Exception::ApiVersionUnsupported) { MLS.handle_response(response) }
  end
  
  test 'handle_response raises ServiceUnavailable on 503' do
    response = mock_response(:get, 503)
    assert_raises(MLS::Exception::ServiceUnavailable) { MLS.handle_response(response) }
  end
  
  test 'handle_response raises Exception on 350, 450, & 550' do
    response = mock_response(:get, 350)
    assert_raises(MLS::Exception) { MLS.handle_response(response) }
    
    response = mock_response(:get, 450)
    assert_raises(MLS::Exception) { MLS.handle_response(response) }
    
    response = mock_response(:get, 550)
    assert_raises(MLS::Exception) { MLS.handle_response(response) }
  end
  
end