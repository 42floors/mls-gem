require 'test_helper'

class TestAccount < ::Test::Unit::TestCase
  
  def test_create_account
    account = FactoryGirl.create(:account)
    assert account.id
  end
  
  def test_create_invalid_account
    account = FactoryGirl.build(:account, :email => nil)
    account.save
    assert account.errors[:email]
  end
  
  def test_search_email
    account = FactoryGirl.create(:account)
    matches = MLS::Account.search(account.email)
    assert_equal [account].map(&:id), matches.map(&:id)
  end

  def test_search_name
    account = FactoryGirl.create(:account)
    matches = MLS::Account.search(account.name)
    assert_equal [account].map(&:id), matches.map(&:id)
  end

end
