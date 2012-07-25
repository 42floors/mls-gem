require 'test_helper'

class TestAccount < ::Test::Unit::TestCase

  def test_properties
    account = MLS::Account.new

    assert account.respond_to?(:id)
    assert account.respond_to?(:role)
    assert account.respond_to?(:name)
    assert account.respond_to?(:email)
    assert account.respond_to?(:password)
    assert account.respond_to?(:password_confirmation)
    assert account.respond_to?(:perishable_token)
    assert account.respond_to?(:perishable_token_set_at)
    assert account.respond_to?(:phone)
    assert account.respond_to?(:company)
    assert account.respond_to?(:license)
    assert account.respond_to?(:linkedin)
    assert account.respond_to?(:twitter)
    assert account.respond_to?(:facebook)
    assert account.respond_to?(:web)
    assert account.respond_to?(:mls_number)
    assert account.respond_to?(:state)
    assert account.respond_to?(:country)
    assert account.respond_to?(:auth_key)
    assert account.respond_to?(:funding)
    assert account.respond_to?(:favorite_ids)
    # assert account.respond_to?(:message)
    assert account.respond_to?(:population)
    assert account.respond_to?(:growing)
    assert account.respond_to?(:move_in)
    assert account.respond_to?(:extra_info)
  end

  def test_methods
    account = MLS::Account.new

    assert account.respond_to?(:update!)
    assert account.respond_to?(:create!)
    assert account.respond_to?(:agent?)
    assert account.respond_to?(:favorites)
    assert account.respond_to?(:favorite)
  end

  def test_class_methods
    assert MLS::Account.respond_to?(:current)
    assert MLS::Account.respond_to?(:authenticate)
    assert MLS::Account.respond_to?(:reset_password!)
    assert MLS::Account.respond_to?(:update_password!)
  end
end
