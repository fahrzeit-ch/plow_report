FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Winterdienst #{n} GmbH"}
    contact_email 'info@company.com'
  end
  factory :company_registration, class: 'Company::Registration' do
    sequence(:name) { |n| "Winterdienst #{n} GmbH"}
    contact_email 'info@company.com'
    add_owner_as_driver '0'
    transfer_private_drives '0'
  end
end
