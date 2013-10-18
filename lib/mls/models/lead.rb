class MLS::Lead < MLS::Resource
  property :id,                           Fixnum,   serialize: :false
  property :created_at,                   DateTime
  property :medium,                       String,   serialize: :false
  property :status,                       String
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

  def save
    MLS.put("/leads/#{id}", {:lead => to_hash}, 400) do |response, code|
      if code == 200 || code == 400
        MLS::Lead::Parser.update(self, response.body)
        code == 200
      else
        raise MLS::Exception::UnexpectedResponse, code
      end
    end
  end

end

class MLS::Lead::Parser < MLS::Parser
end
