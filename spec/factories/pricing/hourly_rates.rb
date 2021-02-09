FactoryBot.define do
  factory :pricing_hourly_rate, class: 'Pricing::HourlyRate' do
    hourly_ratable { association :vehicle }
    price_cents { 1 }
    price_currency { "CHF" }
    valid_from { "2021-02-03 11:48:38" }
  end
end
