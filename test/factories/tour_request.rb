FactoryGirl.define do
  factory :tour_request, :class => MLS::TourRequest do
    message { Faker::Lorem.paragraph }
    company { Faker::Company.email }
    population { Kernel.rand(2..200) }
    funding { Faker::Lorem.sentance }
    move_in_date '1234-12-21'
  end  
end