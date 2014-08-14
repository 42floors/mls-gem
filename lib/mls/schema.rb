#TODO:
# attribute defaults
# move created_at / updated_at to automatically be there? add timestamps helper?
# move slug to a slugger extionsion

# MLS::Listing.define_schema do
#   # :serialize => :false these:
#   #   integer :id,
#   #   belongs_to_ids
#   #   slug
#   #   created_at
#   #   updated_at
#   #   touched_at
#   #   leased_on
#   #   slug
#   #   counters
#   #
#   # needs defaults:
#   #  type
#   #  workflow_state
#   #  lease_state
#   string    :slug
#
#   datetime  :created_at
#   datetime  :updated_at
#   datetime  :touched_at
#
#   string    :state
#
#   string    :lease_state
#   datetime  :leased_on
#
#   string    :name
#   string    :type
#   string    :description
#   string    :synopsis
#
#   string    :space_type
#   string    :unit
#   integer   :floor
#
#   integer   :size
#   integer   :minimum_divisible_size
#   integer   :maximum_contiguous_size
#
#   datetime  :available_on
#   datetime  :sublease_expiration
#   decimal   :rate
#   string    :rate_units
#   integer   :term
#   string    :term_units
#   string    :terms
#
#   string    :uses, :array => true
#   string    :tags, :array => true
#
#   hash      :amenities
#   integer   :offices
#   integer   :conference_rooms
#   integer   :bathrooms
#
# end


MLS::Account.define_schema do
  # :serialize => :false these:
  #   integer :id,
  #   belongs_to_ids
  #   slug
  #   created_at
  #   updated_at
  #   touched_at
  #   leased_on
  #   slug
  #   counters
  #
  # :serialize => :if_present these:
  #  password
  #  password_confirmation
  #
  # needs defaults:
  #  roles
  #  programs


  string    :slug

  datetime  :created_at
  datetime  :updated_at

  string    :name
  string    :nicknames
  string    :email
  string    :phone
  string    :mobile
  string    :title
  string    :company
  string    :license
  string    :linkedin
  string    :twitter
  string    :facebook
  string    :web

  string    :password
  string    :password_confirmation

  datetime  :called_at
  datetime  :reached_at
  string    :contact_preference
  string    :contact_relationship
  boolean   :craigslist_opt_out
  string    :profile_url

  string    :roles,     :array => true
  string    :programs,  :array => true
  string    :tags,  :array => true
end

MLS::Photo.define_schema do
  string  :caption
  string  :digest

  # attribute :created_at, DateTime
  # attribute :updated_at, DateTime
  # attribute :file_content_type, String
  # attribute :file_name, String
  # attribute :file_size, Fixnum
  # attribute :url_template, String
  # attribute :caption, String
  # attribute :subject_id, Fixnum
end
