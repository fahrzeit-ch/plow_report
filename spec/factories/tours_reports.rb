FactoryBot.define do
  factory :tours_report do
    start_date { Time.current.beginning_of_year }
    end_date { Time.current.end_of_month }
    created_by { association :user }
  end
end
