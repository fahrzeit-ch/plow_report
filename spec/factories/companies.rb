FactoryBot.define do
  factory :company,  aliases: [:client_of]  do
    sequence(:name) { |n| "Winterdienst #{n} GmbH"}
    contact_email 'info@company.com'
    address 'Some Street'
    nr '1'
    zip_code '8810'
    city 'Neustadt'
    options(drive_options: { track_distance: true, track_salting: true, track_plowing: true })
  end
  factory :company_registration, class: 'Company::Registration' do
    sequence(:name) { |n| "Winterdienst #{n} GmbH"}
    contact_email 'info@company.com'
    address 'Some Street'
    nr '1'
    zip_code '8810'
    city 'Neustadt'
    add_owner_as_driver false
  end
end
