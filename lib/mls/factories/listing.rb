FactoryGirl.define do
  factory :listing, :class => MLSGem::Listing do
    before(:create) { |l|
      MLSGem_GEM_CACHE['auth_cookie'] = MLSGem.auth_cookie
      MLSGem.auth_cookie = l.account.auth_cookie
    }
    after(:create) { |l|
      MLSGem.auth_cookie = MLSGem_GEM_CACHE['auth_cookie']
    }

    association :account
    association :address, :strategy => :build

    agents  { [FactoryGirl.attributes_for(:agent)] }

    use 'Office'
    size { Kernel.rand(3000..900000) }
    maximum_contiguous_size { Kernel.rand(3000..900000) }
    minimum_divisible_size { Kernel.rand(3000..900000) }
    type 'lease'
    #lease_terms { ::MLSGem::Listing::LEASE_TERMS.sample }
    space_type 'unit'
    rate { rand(15..300) }
    available_on { Time.now + (20 + rand(0..360).to_i).days }
    sublease_expiration { |l| l.sublease? ? (l.available_on + (30 + Kernel.rand(10..360)).days) : nil }
    name { |l| l.type == 'coworking_space' ? Faker::Name.name : nil }
  end
end

