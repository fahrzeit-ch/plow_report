FactoryBot.define do
  factory :route do
    name { "MyString" }
    company { association(:company) }
    site_ordering { Route::CUSTOM_ORDER }
  end
end
