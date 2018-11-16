FactoryBot.define do
  factory :value_activity, aliases: [:activity], class: 'Activity' do
    company nil
    name 'Salting'
    has_value true
    value_label 'Kg'
  end

  factory :boolean_activity, class: 'Activity' do
    company { nil }
    name { 'Plowing' }
    has_value { false }
  end
end
