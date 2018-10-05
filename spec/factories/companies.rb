FactoryBot.define do
  factory :company,  aliases: [:client_of]  do
    sequence(:name) { |n| "Winterdienst #{n} GmbH"}
    contact_email 'info@company.com'
    address 'Some Street 1'
    zip_code '8810'
    city 'Neustadt'
  end
  factory :company_registration, class: 'Company::Registration' do
    sequence(:name) { |n| "Winterdienst #{n} GmbH"}
    contact_email 'info@company.com'
    address 'Some Street 1'
    zip_code '8810'
    city 'Neustadt'
    add_owner_as_driver false
    transfer_private_drives false
  end
end
