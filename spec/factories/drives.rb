FactoryBot.define do
  factory :drive, class: 'Drive' do
    start '2018-02-02'
    add_attribute(:end) { '2018-02-02' }
    plowed false
    salted false
    salt_refilled false
    salt_amount_tonns 1.5
    distance_km 1.5
  end
end
