FactoryGirl.define do
  factory :account, :class => MLS::Account do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'test' }
    password_confirmation 'test'
  end
  
  factory :broker, :class => MLS::Account, :parent => :account do
    role 'broker'
  end
  
  factory :ghost_account, :class => MLS::Account do
    name                    { Faker::Name.name }
    email                   { Faker::Internet.email }
    password_required       { false } 
  end
end