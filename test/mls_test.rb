require 'test_helper'

class MLSTest < Minitest::Test

  def setup
    MLS.url = "http://test_api_key@testhost.com"
    MLS.instance.instance_variable_set(:@server_config, nil)
  end


  # MLS.asset_host ============================================================

  test '#asset_host' do
    stub_request(:get, "http://testhost.com/config").to_return(:body => '{"asset_host": "myhost"}')

    assert_equal( 'myhost', MLS.asset_host )
  end

  # MLS.image_host ============================================================

  test '#image_host' do
    stub_request(:get, "http://testhost.com/config").to_return(:body => '{"image_host": "myhost"}')

    assert_equal( 'myhost', MLS.image_host )
  end

end
