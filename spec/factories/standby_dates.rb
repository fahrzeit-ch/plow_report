FactoryBot.define do
  factory :standby_date do
    driver
    day { Time.zone.today }
  end

  factory :standby_date_date_range, class: 'StandbyDate::DateRange' do
    start_date { Time.zone.yesterday }
    end_date { Time.zone.today }
    driver_id { driver.id }
  end
end
