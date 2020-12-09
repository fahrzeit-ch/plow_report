# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :vehicle_name do |n|
    "Fahrzeug #{n}"
  end

  sequence :site_name do |n|
    "Objekt Hannenbach #{n}"
  end
end
