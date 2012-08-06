FactoryGirl.define do
  factory :listing, :class => MLS::Listing do
    before(:create) { |l|
      Rails.cache.write('auth_key', MLS.auth_key)
      MLS.auth_key = l.account.auth_key
    }
    after(:create) { |l|
      MLS.auth_key = Rails.cache.read('auth_key')
    }

    association :account
    association :address, :strategy => :build

    #agents_attributes  { {'0' => FactoryGirl.attributes_for(:broker)} }

    use 'Office'
    total_size { Kernel.rand(3000..900000) }
    maximum_contiguous_size { Kernel.rand(3000..900000) }
    minimum_divisable_size { Kernel.rand(3000..900000) }
    kind 'lease'
    #lease_type { ::MLS::Listing::LEASE_TYPES.sample }
    space_type 'unit'
    rate { rand(15..300) }
    nnn_expenses { |l| l.lease_type == 'NNN' ? Kernel.rand(15..200) : nil }
    available_on { Time.now + (20 + rand(0..360).to_i).days }
    sublease_expiration { |l| l.sublease? ? (l.available_on + (30 + Kernel.rand(10..360)).days) : nil }
    name { |l| l.kind == 'coworking' ? Faker::Name.name : nil }
  end
end

