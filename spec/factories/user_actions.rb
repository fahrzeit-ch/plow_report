# frozen_string_literal: true

FactoryBot.define do
  factory :user_action do
    activity { "MyString" }
    user { nil }
    target { nil }
  end
end
