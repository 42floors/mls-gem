FactoryGirl.define do
  factory :account, :class => MLS::Account do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'test' }
    password_confirmation 'test'
  end
  
  factory :agent, :class => MLS::Account do
    phone                   { Faker::PhoneNumber.phone_number }
    company                 { Faker::Company.name }
    license                 '12123123123'
    name                    { Faker::Name.name }
    email                   { Faker::Internet.email }
    password                'test'
    password_confirmation   'test'
    type                    'Agent'
  end

  factory :admin, :class => MLS::Account do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    type {'Admin'}
    password { 'admin_test' }
    password_confirmation 'admin_test'
  end
  
end
