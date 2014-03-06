FactoryGirl.define do
  factory :account, :class => MLSGem::Account do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'test' }
    password_confirmation 'test'
  end
  
  factory :agent, :class => MLSGem::Account do
    phone                   { Faker::PhoneNumber.phone_number }
    company                 { Faker::Company.name }
    license                 '12123123123'
    name                    { Faker::Name.name }
    email                   { Faker::Internet.email }
    password                'test'
    password_confirmation   'test'
    type                    'Agent'
  end

  factory :admin, :class => MLSGem::Account do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    type {'Admin'}
    password { 'admin_test' }
    password_confirmation 'admin_test'
  end
  
  factory :ghost_account, :class => MLSGem::Account do
    name                    { Faker::Name.name }
    email                   { Faker::Internet.email }
    password_required       { false } 
  end

end
