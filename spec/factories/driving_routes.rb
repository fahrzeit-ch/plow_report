FactoryBot.define do
  factory :driving_route do
    name { generate(:route_name) }
    company { association(:company) }
    site_ordering { DrivingRoute::CUSTOM_ORDER }
  end

  factory :site_entry, class: "DrivingRoute::SiteEntry" do
    driving_route { association(:driving_route) }
    site { association(:site) }
    position { generate(:unique_position) }
  end

  sequence :unique_position
end
