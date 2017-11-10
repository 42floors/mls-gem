class Action < MLS::Model
  self.inheritance_column = nil
  attr_accessor :account_id
  
  belongs_to :event
  belongs_to :subject, :polymorphic => true

  has_many :mistakes
  has_many :metadata, foreign_key: :event_id, primary_key: :event_id

  def self.by_performer(filter)
    req = Net::HTTP::Get.new("/actions/by_performer")
    req.body = {
      where: filter
    }.to_json
    JSON.parse(connection.instance_variable_get(:@connection).send_request(req).body)
  end
  
end
