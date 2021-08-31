# frozen_string_literal: true

FactoryBot.define do
  factory :vehicle do
    name { generate(:vehicle_name) }
    discarded_at { nil }
    company
    default_driving_route { association(:driving_route, company: company) }
  end
end
