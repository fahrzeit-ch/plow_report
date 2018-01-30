class WeekView
  include ActiveModel::Model

  attr_accessor :start_date
  attr_accessor :day_count

  def initialize(date, count)
    self.start_date = StandbyDate.select(:day).where('day >= ?', date).order(day: :asc).first.day
    self.day_count = count
  end

  def week_nr
    self.start_date.cweek
  end

end

class StandbyDateRange
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment

  attr_accessor :start_date
  attr_accessor :end_date
  attr_accessor :driver_id

  def initialize(attributes={})
    @start_date = Date.today
    @end_date = Date.today
    assign_attributes attributes
  end

  def save
    if valid?
      StandbyDate.from_range start_date, end_date, driver_id
    end
  end
end

class StandbyDate < ApplicationRecord
  belongs_to :driver

  def self.by_season(season)
    where('day > ? AND day < ?', season.start_date, season.end_date)
  end

  def self.from_range(start_day, end_day, driver_id)
    (start_day.to_date..end_day.to_date).each do |date|
      StandbyDate.create day: date, driver_id: driver_id
    end
  end

  def self.weeks
    res = group("DATE_TRUNC('week', day)").order('date_trunc_week_day DESC').count
    res.map { |key, val| WeekView.new key.to_date, val }
  end

  def start_time
    day
  end
end
