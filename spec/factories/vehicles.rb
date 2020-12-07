# frozen_string_literal: true

FactoryBot.define do
  factory :vehicle do
    name { "Unimoc" }
    discarded_at { nil }
    company
  end
end
