FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :site_name do |n|
    "Objekt Hannenbach #{n}"
  end
end