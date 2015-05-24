class Email < MLS::Model

  belongs_to :source
  has_and_belongs_to_many :attachments, :class_name => 'Document'

  def from
    if from_name
      "\"#{from_name}\" <#{from_address}>"
    else
      from_address
    end
  end
  
  def name
    from
  end

  def to
    to_names.zip(to_addresses).map{|t| t[0] ? "\"#{t[0]}\" <#{t[1]}>" : t[1] }.join(', ')
  end

  def cc
    cc_names.zip(cc_addresses).map{|t| t[0] ? "\"#{t[0]}\" <#{t[1]}>" : t[1] }.join(', ')
  end

  def bcc
    bcc_names.zip(bcc_addresses).map{|t| t[0] ? "\"#{t[0]}\" <#{t[1]}>" : t[1] }.join(', ')
  end

  def reply_to
    reply_to_names.zip(reply_to_addresses).map{|t| t[0] ? "\"#{t[0]}\" <#{t[1]}>" : t[1] }.join(', ')
  end

end
