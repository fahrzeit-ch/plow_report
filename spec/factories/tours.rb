FactoryBot.define do
  factory :tour do
    start_time { 1.hour.ago }
    end_time ""
    driver
  end
end
