require 'test_helper'

class TestMLSGem < ::Test::Unit::TestCase

  def test_API_VERSION
    assert_equal "0.1.0", MLSGem::API_VERSION
  end

  def test_attr_accessors
    mls = MLSGem.instance

    assert mls.respond_to?(:url)
    assert mls.respond_to?(:url=)
    assert mls.respond_to?(:api_key)
    assert mls.respond_to?(:auth_cookie)
    assert mls.respond_to?(:logger)
    assert mls.respond_to?(:connection)
    assert mls.respond_to?(:prepare_request)

    assert mls.respond_to?(:put)
    assert mls.respond_to?(:post)
    assert mls.respond_to?(:get)
    assert mls.respond_to?(:delete)

    assert mls.respond_to?(:handle_response)
    assert mls.respond_to?(:ping)
    assert mls.respond_to?(:auth_ping)
    assert mls.respond_to?(:default_logger)
  end

  # MLSGem.get =================================================================

  test '#get' do
    FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get')
    response = MLSGem.get('/test')
    assert_equal 'get', response.body
  end

  test '#get with params' do
    FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test?key=value", :body => 'get')
    response = MLSGem.get('/test', :key => 'value')

    assert_equal '/test?key=value', FakeWeb.last_request.path
  end

  test '#get to 404 raises MLSGem::Exception::NotFound' do
    FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get', :status => ['404', ''])

    assert_raises(MLSGem::Exception::NotFound) { MLSGem.get('/test') }
  end

  test '#get to 404 doesnt raise NotFound if in valid_response_codes' do
    assert_nothing_raised {
      FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get', :status => ['404', ''])
      MLSGem.get('/test', nil, 404)

      FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get', :status => ['404', ''])
      MLSGem.get('/test', nil, 400..499)

      FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get', :status => ['404', ''])
      MLSGem.get('/test', nil, 300..399, 404)

      FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get', :status => ['404', ''])
      MLSGem.get('/test', nil, 404, 300..399)

      FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get', :status => ['404', ''])
      MLSGem.get('/test', nil, [300..399, 404])
    }
  end

  test '#get with block' do
    FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get')
    MLSGem.get('/test') do |response|
      assert_equal 'get', response.body
    end

    # make sure block is not called when not in valid_response_codes
    FakeWeb.register_uri(:get, "#{MLSGem_HOST}/test", :body => 'get', :status => ['401', ''])
    assert_raises(MLSGem::Exception::Unauthorized) {
      MLSGem.get('/test') do |response|
        raise MLSGem::Exception, 'Should not get here'
      end
    }
  end

  # MLSGem.put =================================================================

  test '#put' do
    FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put')
    response = MLSGem.put('/test')
    assert_equal 'put', response.body
  end

  test '#put with a body' do
    FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put')
    response = MLSGem.put('/test', :key => 'value')

    assert_equal '{"key":"value"}', FakeWeb.last_request.body
  end

  test '#put to 404 raises MLSGem::Exception::NotFound' do
    FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put', :status => ['404', ''])

    assert_raises(MLSGem::Exception::NotFound) { MLSGem.put('/test') }
  end

  test '#put to 404 doesnt raise NotFound if in valid_response_codes' do
    assert_nothing_raised {
      FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put', :status => ['404', ''])
      MLSGem.put('/test', nil, 404)

      FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put', :status => ['404', ''])
      MLSGem.put('/test', nil, 400..499)

      FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put', :status => ['404', ''])
      MLSGem.put('/test', nil, 300..399, 404)

      FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put', :status => ['404', ''])
      MLSGem.put('/test', nil, 404, 300..399)

      FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put', :status => ['404', ''])
      MLSGem.put('/test', nil, [300..399, 404])
    }
  end

  test '#put with block' do
    FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put')
    MLSGem.put('/test') do |response|
      assert_equal 'put', response.body
    end

    # make sure block is not called when not in valid_response_codes
    FakeWeb.register_uri(:put, "#{MLSGem_HOST}/test", :body => 'put', :status => ['401', ''])
    assert_raises(MLSGem::Exception::Unauthorized) {
      MLSGem.put('/test') do |response|
        raise MLSGem::Exception, 'Should not get here'
      end
    }
  end

  # MLSGem.post =================================================================

  test '#post' do
    FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post')
    response = MLSGem.post('/test')
    assert_equal 'post', response.body
  end

  test '#post with a body' do
    FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post')
    response = MLSGem.post('/test', :key => 'value')

    assert_equal '{"key":"value"}', FakeWeb.last_request.body
  end

  test '#post to 404 raises MLSGem::Exception::NotFound' do
    FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post', :status => ['404', ''])

    assert_raises(MLSGem::Exception::NotFound) { MLSGem.post('/test') }
  end

  test '#post to 404 doesnt raise NotFound if in valid_response_codes' do
    assert_nothing_raised {
      FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post', :status => ['404', ''])
      MLSGem.post('/test', nil, 404)

      FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post', :status => ['404', ''])
      MLSGem.post('/test', nil, 400..499)

      FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post', :status => ['404', ''])
      MLSGem.post('/test', nil, 300..399, 404)

      FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post', :status => ['404', ''])
      MLSGem.post('/test', nil, 404, 300..399)

      FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post', :status => ['404', ''])
      MLSGem.post('/test', nil, [300..399, 404])
    }
  end

  test '#post with block' do
    FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post')
    MLSGem.post('/test') do |response|
      assert_equal 'post', response.body
    end

    # make sure block is not called when not in valid_response_codes
    FakeWeb.register_uri(:post, "#{MLSGem_HOST}/test", :body => 'post', :status => ['401', ''])
    assert_raises(MLSGem::Exception::Unauthorized) {
      MLSGem.post('/test') do |response|
        raise MLSGem::Exception, 'Should not get here'
      end
    }
  end

  # MLSGem.delete ================================================================

  test '#delete' do
    FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete')
    response = MLSGem.delete('/test')
    assert_equal 'delete', response.body
  end

  test '#delete with a body' do
    FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete')
    response = MLSGem.delete('/test', :key => 'value')

    assert_equal '{"key":"value"}', FakeWeb.last_request.body
  end

  test '#delete to 404 raises MLSGem::Exception::NotFound' do
    FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete', :status => ['404', ''])

    assert_raises(MLSGem::Exception::NotFound) { MLSGem.delete('/test') }
  end

  test '#delete to 404 doesnt raise NotFound if in valid_response_codes' do
    assert_nothing_raised {
      FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLSGem.delete('/test', nil, 404)

      FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLSGem.delete('/test', nil, 400..499)

      FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLSGem.delete('/test', nil, 300..399, 404)

      FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLSGem.delete('/test', nil, 404, 300..399)

      FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete', :status => ['404', ''])
      MLSGem.delete('/test', nil, [300..399, 404])
    }
  end

  test '#delete with block' do
    FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete')
    MLSGem.delete('/test') do |response|
      assert_equal 'delete', response.body
    end

    # make sure block is not called when not in valid_response_codes
    FakeWeb.register_uri(:delete, "#{MLSGem_HOST}/test", :body => 'delete', :status => ['401', ''])
    assert_raises(MLSGem::Exception::Unauthorized) {
      MLSGem.delete('/test') do |response|
        raise MLSGem::Exception, 'Should not get here'
      end
    }
  end

  # MLSGem.handle_response ======================================================

  test 'handle_response raises BadRequest on 400' do
    response = mock_response(:get, 400)
    assert_raises(MLSGem::Exception::BadRequest) { MLSGem.handle_response(response) }
  end

  test 'handle_response raises Unauthorized on 401' do
    response = mock_response(:get, 401)
    assert_raises(MLSGem::Exception::Unauthorized) { MLSGem.handle_response(response) }
  end

  test 'handle_response raises NotFound on 404' do
    response = mock_response(:get, 404)
    assert_raises(MLSGem::Exception::NotFound) { MLSGem.handle_response(response) }
  end

  test 'handle_response raises NotFound on 410' do
    response = mock_response(:get, 410)
    assert_raises(MLSGem::Exception::NotFound) { MLSGem.handle_response(response) }
  end

  test 'handle_response raises ApiVersionUnsupported on 422' do
    response = mock_response(:get, 422)
    assert_raises(MLSGem::Exception::ApiVersionUnsupported) { MLSGem.handle_response(response) }
  end

  test 'handle_response raises ServiceUnavailable on 503' do
    response = mock_response(:get, 503)
    assert_raises(MLSGem::Exception::ServiceUnavailable) { MLSGem.handle_response(response) }
  end

  test 'handle_response raises Exception on 350, 450, & 550' do
    response = mock_response(:get, 350)
    assert_raises(MLSGem::Exception) { MLSGem.handle_response(response) }

    response = mock_response(:get, 450)
    assert_raises(MLSGem::Exception) { MLSGem.handle_response(response) }

    response = mock_response(:get, 550)
    assert_raises(MLSGem::Exception) { MLSGem.handle_response(response) }
  end

end
