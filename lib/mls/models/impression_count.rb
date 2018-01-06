class ImpressionCount < MLS::Model
  belongs_to :subject, polymorphic: true
  
  def self.by_day(**body)
    req = Net::HTTP::Get.new("/impression_counts/by_day")
    req.body = body.to_json
    connection.instance_variable_get(:@connection).send_request(req).body
  end
  
  def self.by_week(**body)
    req = Net::HTTP::Get.new("/impression_counts/by_week")
    req.body = body.to_json
    connection.instance_variable_get(:@connection).send_request(req).body
  end
  
  def self.by_month(**body)
    req = Net::HTTP::Get.new("/impression_counts/by_month")
    req.body = body.to_json
    connection.instance_variable_get(:@connection).send_request(req).body
  end
end