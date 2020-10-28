FactoryBot.define do
  factory :user do
    name { 'Sample User' }
    email
    password { 'secret' }
    password_confirmation { 'secret' }
  end
end
