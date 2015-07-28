class Region < MLS::Model
  
  include MLS::Slugger
  
  self.inheritance_column = nil

  belongs_to :cover_photo, :class_name => 'Image'
  belongs_to :market, :class_name => 'Region'
  
  has_one  :geometry, as: :subject
  has_many :stats, -> { order(:created_at => :asc) }, as: :subject
    
  has_and_belongs_to_many :parents, :join_table => 'regions_regions', :class_name => 'Region', :foreign_key => 'child_id', :association_foreign_key => 'parent_id'
  has_and_belongs_to_many :children, :join_table => 'regions_regions', :class_name => 'Region', :foreign_key => 'parent_id', :association_foreign_key => 'child_id'
  
  def name
    if common_name.try(:[], 'eng')
      common_name['eng'].is_a?(Array) ? common_name['eng'].first : common_name['eng']
    else
      official_name['eng'].is_a?(Array) ? official_name['eng'].first : official_name['eng']
    end
  end
  
  def target
    return @target if @target
    @target = children.where(:target => true).first
    @target ||= market.try(:target)
    @target ||= market
    @target ||= self
    
    @target
  end
  
  def cover_photo_url(options={})

    options.reverse_merge!({
      :style => nil,
      :bg => nil,
      :protocol => 'https',
      :format => "jpg",
      :host => MLS.image_host
    });

    url_params = { s: options[:style], bg: options[:bg] }.select{ |k, v| v }

    if options[:protocol] == :relative # Protocol Relative
      result = '//'
    else options[:protocol]
      result = "#{options[:protocol]}://"
    end

    result += "#{options[:host]}/#{cover_photo_digest}.#{options[:format]}"
    result += "?#{url_params.to_param}" if url_params.size > 0

    result
  end

end