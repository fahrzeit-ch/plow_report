FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Winterdienst #{n} GmbH"}
    options '{}'
  end
end
