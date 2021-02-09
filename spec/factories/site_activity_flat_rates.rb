FactoryBot.define do
  factory :site_activity_flat_rate do
    site { association :site }
    activity { association :activity }
    activity_fee_attributes { { active: true, valid_from: Season.current.start_date, price: "20" } }
  end
end
