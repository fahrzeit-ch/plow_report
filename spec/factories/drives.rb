FactoryBot.define do
  factory :drive, class: 'Drive' do
    start 1.hour.ago
    add_attribute(:end) { Time.now }
    plowed false
    salted false
    salt_refilled false
    salt_amount_tonns 1.5
    distance_km 1.5
  end
end
