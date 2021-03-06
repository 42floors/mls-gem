class Task < MLS::Model
  self.inheritance_column = nil

  belongs_to  :subject, :polymorphic => true
  belongs_to  :account
  belongs_to  :source
  belongs_to  :team
  
  has_many :events
  has_many :mistakes
  has_many :time_logs
  has_many :reviews, -> { where(:type => "review") }, :class_name => "Task", :as => :subject, :inverse_of => :subject
  has_many :fixes, -> { where(:type => "fix") }, :class_name => "Task", :as => :subject, :inverse_of => :subject
  
  has_and_belongs_to_many :regions

  def for_source?
    subject_type == "Source"
  end
  
  def for_task?
    subject_type == "Task"
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
  
  def crawl?
    type == "crawl"
  end
  
  def paused?
    status == 'paused'
  end
  
  def duration
      time_logs.where(TimeLog.arel_table[:started_at].not_eq(nil)).where(TimeLog.arel_table[:stopped_at].not_eq(nil)).sum("duration")
  end
  
  def pause
    log = time_logs.where(:stopped_at => nil).where(TimeLog.arel_table[:started_at].not_eq(nil)).first
    if log
      log.update(:stopped_at => Time.now)
    end
  end
  
  def resume
    #time_logs << TimeLog.create(:started_at => Time.now)
    TimeLog.create(task_id: self.id, started_at: Time.now)
  end
  
end
