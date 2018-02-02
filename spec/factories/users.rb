FactoryBot.define do
  factory :user do
    name 'Sample User'
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password 'secret'
    password_confirmation 'secret'
  end
end
