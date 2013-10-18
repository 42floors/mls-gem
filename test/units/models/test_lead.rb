require 'test_helper'

class LeadTest < Test::Unit::TestCase

  test 'lead responds to properties' do
    lead = MLS::Lead.new

    [:id, :created_at, :medium, :status, :client_id, :listing_id, :lead_notifications].each do | property|
      assert lead.respond_to?(property), "lead should respond to #{property}"
    end
  end

  test 'leads can be fetched' do
    agent = MLS::Account.find(4611)
    lead = MLS::Lead.search(agent).first

    assert_instance_of MLS::Lead, lead
  end

  test 'leads can be saved' do
    agent = MLS::Account.find(4611)
    lead = MLS::Lead.search(agent).first
    lead.status = "active"

    lead.save

    updated_lead = MLS::Lead.search(agent).first
    assert_equal "active", updated_lead.status
  end

end
