class Season
  @@winter_season_start_day = { day: 31, month: 10, hash: 1031 }
  @@winter_season_end_day = { day: 30, month: 3, hash: 330 }

  class << self

    def start_day
      @@winter_season_start_day
    end

    def end_day
      @@winter_season_end_day
    end

    def current
      from_date Date.today
    end

    def from_sym(symbol)
      years = symbol.to_s.split '_'
      s = Season.new
      s.start_date = Date.new years[0].to_i, Season.start_day[:month], Season.start_day[:day]
      s.end_date = Date.new years[1].to_i, Season.end_day[:month], Season.end_day[:day]
      s
    end

    def next
      from_date(Season.new.end_date + 1.day)
    end

    def last(num=1)
      range = (num-1..0)
      (range.first).downto(range.last).map { |i| from_date(Season.new.start_date - i.years + 1.day) }
    end

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

  def initialize(date = Date.today)
    self.start_date = Date.new Season.season_start_year_for_date(date), Season.start_day[:month], Season.start_day[:day]
    self.end_date = Date.new Season.season_end_year_for_date(date), Season.end_day[:month], Season.end_day[:day]
  end

  def to_param
    "#{start_date.year}_#{end_date.year}".to_sym
  end

  def to_s
    "Winter #{start_date.year}/#{end_date.year}"
  end

end