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
    if to_names
      to_names.zip(to_addresses).map{|t| t[0] ? "\"#{t[0]}\" <#{t[1]}>" : t[1] }.join(', ')
    else
      to_addresses
    end
  end
  
  def sender
    headers['Sender']
  end

  def cc
    if cc_names
      cc_names.zip(cc_addresses).map{|t| t[0] ? "\"#{t[0]}\" <#{t[1]}>" : t[1] }.join(', ')
    else
      cc_addresses
    end
  end

  def bcc
    if bcc_names
      bcc_names.zip(bcc_addresses).map{|t| t[0] ? "\"#{t[0]}\" <#{t[1]}>" : t[1] }.join(', ')
    else
      bcc_addresses
    end
  end

  def reply_to
    if reply_to_names
      reply_to_names.zip(reply_to_addresses).map{|t| t[0] ? "\"#{t[0]}\" <#{t[1]}>" : t[1] }.join(', ')
    else
      reply_to_addresses
    end
  end
  
  def multipart?
    body.keys.size > 1
  end
  
  def parts
    body.keys
  end

end
