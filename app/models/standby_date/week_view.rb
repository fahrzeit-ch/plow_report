class StandbyDate
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
end
