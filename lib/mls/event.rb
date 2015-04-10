class Event < MLS::Model
  
  SOURCE_TYPES = %w(call email website)
  
  belongs_to :account
  belongs_to :task
  
  has_many :event_actions, :dependent => :destroy
  
  has_many :regards, :dependent => :destroy
  
  def actions
    event_actions.map(&:action)
  end
  
  def regarding
    regards.map(&:thing)
  end
  
end