FactoryBot.define do
  factory :pricing_flat_rate, class: 'Pricing::FlatRate' do
    flat_ratable { association :site }
    price_cents { 1 }
    price_currency { "CHF" }
    valid_from { "2021-02-03 11:51:08" }
    rate_type { Pricing::FlatRate::ACTIVITY_FEE }
    active { true }
  end
end
