FactoryBot.define do
  factory :driver_application do
    user
    recipient { "mail@test.com" }
  end
end
