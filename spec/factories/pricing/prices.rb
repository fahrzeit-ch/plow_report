FactoryBot.define do
  factory :pricing_price, class: 'Pricing::Price' do
    price_cents { 1 }
    price_currency { "MyString" }
    valid_from { "2021-02-03 11:11:57" }
  end
end
