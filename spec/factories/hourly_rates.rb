# frozen_string_literal: true

FactoryBot.define do
  factory :hourly_rate do
    price_cents { 1000 }
    price_currency { "CHF" }
    company
    activity
    customer
  end
end
