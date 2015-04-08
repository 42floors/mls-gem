class EventAction < MLS::Model
  
  belongs_to :event
  belongs_to :action, polymorphic: true
  
end
