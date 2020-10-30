# frozen_string_literal: true

FactoryBot.define do
  factory :activity_execution do
    activity
    drive
  end

  factory :activity_execution_with_value, class: "ActivityExecution" do
    activity { create(:value_activity) }
    drive
    value { 12 }
  end
end
