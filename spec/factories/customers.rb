FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "customer #{n}" }
    client_of
  end
end
