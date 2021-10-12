# frozen_string_literal: true

FactoryBot.define do
  factory :value_activity, class: "Activity" do
    company { nil }
    name { generate(:activity_name_seq) }
    has_value { true }
    value_label { "Kg" }
  end

  factory :boolean_activity, aliases: [:activity], class: "Activity" do
    company { nil }
    name { generate(:activity_name_seq) }
    has_value { false }
  end

  sequence :activity_name_seq do |n|
    "Salting #{n}"
  end
end
