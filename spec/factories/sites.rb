# frozen_string_literal: true

FactoryBot.define do
  factory :site do
    display_name { generate(:site_name) }
    name { "Muster" }
    first_name { "Max" }
    street { "Sennstrasse" }
    nr { "1 - 6" }
    zip { "5999" }
    city { "Superstadt" }
    customer
    active { true }
  end
end
