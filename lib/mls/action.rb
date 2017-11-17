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
  
  def self.squash(attributes)
    squashed_actions = []
    where(nil).each do |action|
      action.account_id = action.metadata.where(key: 'performed_by_id').first&.value
      
      action.diff = action.diff.slice(*attributes) if attributes
      if squashed_actions.last &&
        action.account_id == squashed_actions.last.account_id &&
        action.timestamp + 15.minutes > squashed_actions.last.timestamp

        action.diff.each do |key, value|
          next if value[0] == value[1] # filter sometimes logs even if the same
          if squashed_actions.last.diff[key]
            squashed_actions.last.diff[key][0] = value[0]
          else
            squashed_actions.last.diff[key] = value
          end
        end
      else
        squashed_actions << action
      end
    end
    squashed_actions
  end
  
end
