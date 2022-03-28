FactoryBot.define do
  factory :pricing_flat_rate, class: 'Pricing::FlatRate' do
    flat_ratable { association :site }
    price_cents { 1 }
    price_currency { "CHF" }
    valid_from { 1.day.ago }
    rate_type { Pricing::FlatRate::ACTIVITY_FEE }
    active { true }
  end
end
