class StandbyDate < ApplicationRecord
  belongs_to :driver
  audited associated_with: :driver

  validates :day, uniqueness: { scope: :driver }

  def self.by_season(season)
    where('day > ? AND day < ?', season.start_date, season.end_date)
  end

  def self.from_range(start_day, end_day, driver_id)
    successful_dates = []
    (start_day.to_date..end_day.to_date).each do |date|
      date = StandbyDate.create day: date, driver_id: driver_id
      successful_dates << date if date.errors.empty?
    end
    successful_dates
  end

  def self.weeks
    res = group("DATE_TRUNC('week', day)").order('date_trunc_week_day DESC').count
    res.map { |key, val| WeekView.new key.to_date, val }
  end

  def start_time
    day
  end
end
