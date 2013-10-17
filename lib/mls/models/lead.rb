class MLS::Lead < MLS::Resource
  property :id,                           Fixnum,   serialize: :false
  property :created_at,                   DateTime
  property :medium,                       String,   serialize: :false
  property :client_id,                    Fixnum
  property :listing_id,                   Fixnum
  property :lead_notifications,           Array

  class << self
    # find all the leads for a given agent
    def search(agent)
      response = MLS.get('/leads', {where: {agent: {id: agent.id}}})
      MLS::Lead::Parser.parse_collection(response.body)
    end
  end
end

class MLS::Lead::Parser < MLS::Parser
end
