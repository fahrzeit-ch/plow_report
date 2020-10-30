# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "customer #{n}" }
    client_of
  end
end
