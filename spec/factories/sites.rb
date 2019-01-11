FactoryBot.define do
  factory :site do
    name { generate(:site_name) }
    street "Sennstrasse"
    nr "1 - 6"
    zip "5999"
    city "Superstadt"
    customer
    active true
  end
end
