# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    sequence(:company_name) { |n| "Company #{n}" }
    sequence(:name) { |n| "customer #{n}" }
    client_of
  end
end
