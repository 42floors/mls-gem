FactoryGirl.define do
  factory :contact, :class => MLS::Contact do
    message { Faker::Lorem.paragraph }
    company { Faker::Company.email }
    population { Kernel.rand(2..200) }
    funding { Faker::Lorem.sentance }
    move_in_date '1234-12-21'
  end  
end