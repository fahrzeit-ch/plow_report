# frozen_string_literal: true

# A season is a date range described by a start and end date. Currently
# Only winter season are supported. As they span across two different years
# they are identified by :year1_year2
#
# TODO: Extend season class to support summer/autumn/spring
class Season
  @@winter_season_start_day = { day: 1, month: 7, hash: 701 }
  @@winter_season_end_day = { day: 30, month: 6, hash: 630 }

  class << self
    def start_day
      @@winter_season_start_day
    end

    def end_day
      @@winter_season_end_day
    end

    # Returns the current season based on Date.current
    def current
      from_date Date.current
    end

    # Parses the season based on the given identifier
    # This currently only supports winter seasons that are
    # identified by two year numbers. For example: :2017_2018
    def from_sym(symbol)
      years = symbol.to_s.split "_"
      s = Season.new
      s.start_date = Date.new years[0].to_i, Season.start_day[:month], Season.start_day[:day]
      s.end_date = Date.new years[1].to_i, Season.end_day[:month], Season.end_day[:day]
      s
    end

    # Returns the next upcomming season
    def next
      from_date(Season.new.end_date + 1.day)
    end

    # Returns an array with the last {n} seasons, including current. Oldest first.
    # Be aware that Season.last(1) is equal to Season.current
    def last(num = 1)
      range = (num - 1..0)
      (range.first).downto(range.last).map { |i| from_date(Season.new.start_date - i.years + 1.day) }
    end

    def previous
      last(2).first
    end

    # Returns the season that includes the given dcate
    def from_date(date)
      Season.new date
    end

    def day_hash(date)
      date.month * 100 + date.mday
    end

    def season_start_year_for_date(date)
      if day_hash(date) < @@winter_season_end_day[:hash]
        date.year - 1
      else
        date.year
      end
    end

    def season_end_year_for_date(date)
      if day_hash(date) > @@winter_season_start_day[:hash]
        date.year + 1
      else
        date.year
      end
    end
  end

  attr_accessor :start_date
  attr_accessor :end_date

  def initialize(date = Date.current)
    self.start_date = Date.new Season.season_start_year_for_date(date), Season.start_day[:month], Season.start_day[:day]
    self.end_date = Date.new Season.season_end_year_for_date(date), Season.end_day[:month], Season.end_day[:day]
  end

  def to_param
    "#{start_date.year}_#{end_date.year}".to_sym
  end

  def to_s
    "Winter #{start_date.year}/#{end_date.year}"
  end

  def ==(other)
    self.start_date == other.start_date
  end
end
