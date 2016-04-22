class Change < MLS::Model
  self.inheritance_column = nil
  
  belongs_to :event
  belongs_to :subject, :polymorphic => true
  
  has_many :mistakes
  
  filter_on :diff, -> (v) {
    raise "needs to be hash" if !v.is_a? Hash
    raise "missing keys for diff filter" if ([:key, :operator, :value, :index] - v.keys).length > 0

    where(Change.arel_table[:diff][v[:key].to_sym][v[:index]].send(v[:operator], v[:value].to_s))
  }
  
  filter_on :account_id, -> (v) {
    if v == true
      where(Change.arel_table[:account_id].not_eq(:nil))
    else
      where(:account_id => v)
    end
  }
  
  filter_on :subject_exists, -> (v){
    where(:subject_exists => v)
  }
    
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
