class Change < MLS::Model
  self.inheritance_column = nil
  
  belongs_to :subject, :polymorphic => true
  has_many :event_actions, :as => :action
  has_many :mistakes
  
  def events
    event_actions.map(&:event)
  end
  
  # Returns the association instance for the given name, instantiating it if it doesn't already exist
  def association(name) #:nodoc:
    association = super

    return association if name.to_s != 'subject'

    association.instance_exec do
      def klass
        type = owner[reflection.foreign_type]
        type.presence && type.constantize
      rescue NameError
        nil
      end

      def reader(force_reload=false)
        if klass
          if force_reload
            klass.uncached { reload }
          elsif !loaded? || stale_target?
            reload
          end

          target
        else
          nil
        end
      end
    end

    association
  end
  
end
