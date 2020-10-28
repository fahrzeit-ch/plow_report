FactoryBot.define do
  factory :company_member do
    user
    company
    role { CompanyMember::OWNER }
  end

  factory :company_member_invite, class: 'CompanyMember' do
    user_name { 'User1' }
    role { CompanyMember::OWNER }
    company
    user_email { generate(:email) }
  end
end
