FactoryBot.define do
  factory :company_member do
    user
    company
    role CompanyMember::OWNER
  end
end
