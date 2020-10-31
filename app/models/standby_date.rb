# frozen_string_literal: true

class StandbyDate < ApplicationRecord
  belongs_to :driver
  audited associated_with: :driver

  # Returns a relation of upcoming standby dates. Returns the next
  # 10 by default. An other limit may be provided.
  scope :upcoming, ->(num = 10) { where("day >= ?", Date.current).order(day: :asc).limit(num) }

  validates :day, uniqueness: { scope: :driver }

  # Scopes records to the month of the given date. Additionally events
  # in the beginning of week and end of week of first/last week of the
  # month are loaded.
  #
  # This scope corresponds to the way SimpleCalendar shows a month view.
  def self.by_calendar_month(date)
    start = date.beginning_of_month.beginning_of_week
    to = date.end_of_month.end_of_week
    from_date(start).until_date(to)
  end

  # Returns standby dates that have day greater or equal than given date
  # @param [Date | DateTime] date
  def self.from_date(date)
    where arel_table["day"].gteq(date)
  end

  # Returns standby dates that have day less or equal than given date
  # # @param [Date | DateTime] date
  def self.until_date(date)
    where arel_table["day"].lteq(date)
  end

  # Scopes all standby dates within the given season
  def self.by_season(season)
    from_date(season.start_date).until_date(season.end_date)
  end

  # Create a standby date for each day in the given range
  def self.from_range(start_day, end_day, driver_id)
    successful_dates = []
    (start_day.to_date..end_day.to_date).each do |date|
      date = StandbyDate.create day: date, driver_id: driver_id
      successful_dates << date if date.errors.empty?
    end
    successful_dates
  end

  def self.weeks
    res = group("DATE_TRUNC('week', day)").order("date_trunc_week_day DESC").count
    res.map { |key, val| WeekView.new key.to_date, val }
  end

  # Returns the last standby date of the given season.
  # Returns nil if the season does not contain any.
  #
  # @param [Season] season
  def self.last_in_season(season)
    by_season(season).last
  end

  def start_time
    day
  end
end
