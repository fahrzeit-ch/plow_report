FactoryBot.define do
  factory :standby_date do
    driver
    day Date.today
  end

  factory :standby_date_date_range, class: 'StandbyDate::DateRange' do
    start_date Date.yesterday
    end_date Date.today
    driver_id { driver.id }
  end
end
