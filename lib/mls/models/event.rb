class Event < MLS::Model
  
  SOURCE_TYPES = %w(call email website)
  
  belongs_to :account
  belongs_to :task
  belongs_to :api_key
  
  has_many :actions
  
  has_many :regards
  
  enum type: { create: 0, update: 1, delete: 2 }, _suffix: true
  
  def regarding
    regards.map(&:thing)
  end
  
  def encapsulate(&block)
    Thread.current[:sunstone_headers] ||= {}
    Thread.current[:sunstone_headers]['Event-Id'] = self.id
    yield
    self
  ensure
    Thread.current[:sunstone_headers].delete('Event-Id')
  end

  # Allow you to encapsulate all modification to be attached to a single event
  #
  #   Event.encapsulate(source: '...', source_type: 'API') do
  #     ...
  #   end
  #
  # Returns the event is needed in the future
  def self.encapsulate(options={}, &block)
    event = Event.create!(options)
    Thread.current[:sunstone_headers] ||= {}
    Thread.current[:sunstone_headers]['Event-Id'] = event.id
    yield
    event
  ensure
    Thread.current[:sunstone_headers].try(:delete, 'Event-Id')
  end
  
end
