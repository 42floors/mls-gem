FactoryGirl.define do
  factory :tour, :class => MLS::Tour do
    message { Faker::Lorem.paragraph }
    company { Faker::Company.email }
    population { Kernel.rand(2..200) }
    funding { Faker::Lorem.sentance }
    move_in_date '1234-12-21'
  end  
end