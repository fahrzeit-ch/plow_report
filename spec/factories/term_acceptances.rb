# frozen_string_literal: true

FactoryBot.define do
  factory :term_acceptance do
    user { nil }
    policy_term { nil }
    term_version { 1 }
  end
end
