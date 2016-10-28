class View < MLS::Model
  belongs_to :subject, polymorphic: true
  
  def self.by_day(filter)
    req = Net::HTTP::Get.new("/views/by_day")
    req.body = {
      where: filter
    }.to_json
    connection.instance_variable_get(:@connection).send_request(req).body
  end
end