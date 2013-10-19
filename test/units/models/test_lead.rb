require 'test_helper'

class LeadTest < Test::Unit::TestCase

  test 'lead responds to properties' do
    lead = MLS::Lead.new

    [:id, :created_at, :medium, :status, :client_id, :listing_id, :lead_notifications].each do | property|
      assert lead.respond_to?(property), "lead should respond to #{property}"
    end
  end

  test 'leads can be built' do
    client = FactoryGirl.create(:account)
    lead = MLS::Lead.new(medium: 'web', client_id: client.id )

    assert lead
    assert_equal 'web', lead.medium
    assert_equal client.id, lead.client_id
  end

  test 'Lead parser creates lead from appropriate json' do
    json_object = { lead:{
      id: 3,
      medium: 'web',
      status: 'active',
      client: {
        id: 501,
        name: "new lead client",
        email: "newlead@company.com",
        phone: "1-650-555-7777",
        company: "Business Inc."
      },
      listing: {
        id: 500,
        size: 1000,
        unit: 3,
        address: {
          formatted_address: "123 Main St, San Francisco, CA 94105"
        }
      },
      lead_notifications: [ {
          response: true,
          response_at: 2.days.ago
        }
      ]
    }}

    json = json_object.to_json
    lead = MLS::Lead::Parser.parse json

    assert_instance_of MLS::Lead, lead
    assert_equal 'web', lead.medium
    assert_equal 501, lead.client.id
    assert_equal 500, lead.listing.id
    assert_equal "123 Main St, San Francisco, CA 94105", lead.listing.address.formatted_address
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
