class TimeLog < MLS::Model
  
  belongs_to :task
  
  scope :completed,   -> { where('started_at IS NOT NULL AND stopped_at IS NOT NULL') }
  scope :incompleted,   -> { where('started_at IS NOT NULL AND stopped_at IS NULL') }
  
  def duration
    return nil if !(started_at && stopped_at)
    stopped_at - started_at
  end
  
end
