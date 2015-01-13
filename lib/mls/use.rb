class Use < MLS::Model

  include MLS::Slugger
  # has_ltree_hierarchy

  has_many :children, class_name: 'Use', foreign_key: 'parent_id', inverse_of: :parent
  
  has_and_belongs_to_many :units
  # has_and_belongs_to_many :properties

  def descendants(uses = nil)
    # Recursive self + children of children
    uses ||= [self]
    self.children.each do |child|
      uses << child
      uses = child.descendants(uses)
    end
    uses
  end
  
  # # Scope taken from https://github.com/RISCfuture/hierarchy/blob/master/lib/hierarchy.rb
  # def self.self_and_descendents_of(use)
  #   where("path <@ ?", use.path)
  # end

end
