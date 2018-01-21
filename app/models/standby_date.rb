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

class StandbyDate < ApplicationRecord
  def self.from_range(start_day, end_day)
    (start_day.to_date..end_day.to_date).each do |date|
      StandbyDate.create day: date
    end
  end

  def self.weeks
    res = group("DATE_TRUNC('week', day)").order('date_trunc_week_day DESC').count
    res.map { |key, val| WeekView.new key.to_date, val }
  end
end
