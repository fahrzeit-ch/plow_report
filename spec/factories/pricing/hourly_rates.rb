FactoryBot.define do
  factory :pricing_hourly_rate, class: 'Pricing::HourlyRate' do
    hourly_ratable { association :vehicle }
    price_cents { 1 }
    price_currency { "CHF" }
    valid_from { 1.day.ago }
  end
end
