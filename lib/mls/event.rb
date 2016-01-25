class Event < MLS::Model
  
  SOURCE_TYPES = %w(call email website)
  
  belongs_to :account
  belongs_to :task
  belongs_to :api_key
  
  has_many :event_actions
  
  has_many :regards
  
  def actions
    event_actions.map(&:action)
  end
  
  def regarding
    regards.map(&:thing)
  end
  
end