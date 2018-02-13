FactoryBot.define do
  factory :company_member do
    user
    company
    role 'owner'
  end
end
