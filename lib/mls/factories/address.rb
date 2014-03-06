FactoryGirl.define do
  factory :address, :class => MLSGem::Address do
    street_number { Kernel.rand(1000).to_s }
    street        { Faker::Address.street_name }
    neighborhood  { Faker::Name.name }
    city          { Faker::Address.city }
    county        { |p| p.city }
    state         { Faker::Address.state_abbr }
    country       'US'
    postal_code   { Faker::Address.zip_code }
    formatted_address { |p| "#{p.street_number} #{p.street}, #{p.city}, #{p.state}, #{p.postal_code}" }
    latitude      { Kernel.rand((-90.0)..(90.0)) }
    longitude     { Kernel.rand((-180.0)..(180.0)) }
  end
end

