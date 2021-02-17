# frozen_string_literal: true

FactoryBot.define do
  factory :drive, class: "Drive" do
    start { 1.hour.ago }
    add_attribute(:end) { Time.current }
    driver
    activity_execution { nil }
    site { association(:site) }
  end
end
