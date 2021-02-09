# frozen_string_literal: true

FactoryBot.define do
  factory :vehicle_activity_assignment do
    vehicle { association :vehicle }
    activity { association :activity }
  end
end
