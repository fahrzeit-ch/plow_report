FactoryBot.define do
  factory :drive, class: 'Drive' do
    start 1.hour.ago
    add_attribute(:end) { Time.now }
    driver
    activity_execution { nil }
  end
end
