# frozen_string_literal: true

FactoryBot.define do
  factory :policy_term do
    key { :agb }
    short_description { "MyText" }
    description { "MyText" }
    name { "MyString" }
    version_date { 1.day.ago }
  end
end
