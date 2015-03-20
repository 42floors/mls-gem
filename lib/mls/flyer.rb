class Flyer < MLS::Model

  include MLS::Avatar
  
  has_one :listing
  
  def url
    "http://#{MLS.asset_host}/flyers/#{digest}/compressed/#{file_name}"
  end
    
end