class Task < MLS::Model
  self.inheritance_column = nil

  belongs_to  :subject, :polymorphic => true
  belongs_to  :account
  
  has_many :events
  has_many :mistakes
  has_many :time_logs
  has_many :reviews, -> { where(:type => "review") }, :class_name => "Task", :as => :subject, :inverse_of => :subject
  has_many :fixes, -> { where(:type => "fix") }, :class_name => "Task", :as => :subject, :inverse_of => :subject
  
  def for_source?
    subject_type == "Source"
  end
  
  def for_task?
    subject_type == "Taks"
  end
  
  def review?
    type == "review"
  end
  
  def fix?
    type == "fix"
  end
  
  def parse?
    type == "parse"
  end
  
  def duration
    time_logs.where(:started_at => true, :stopped_at => true).sum("duration")
  end
  
  def pause
    log = time_logs.where(:started_at => true, :stopped_at => false).first
    if log
      log.update(:stopped_at => Time.now)
    end
  end
  
  def resume
    time_logs << TimeLog.create(:started_at => Time.now)
  end
  
  def paused?
    !started_at.nil? && completed_at.nil? && time_logs.where(:started_at => true, :stopped_at => false).length == 0
  end
  
end
