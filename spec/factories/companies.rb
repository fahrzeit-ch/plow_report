FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Winterdienst #{n} GmbH"}
    contact_email 'info@company.com'
    options '{}'
  end
end
