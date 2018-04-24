class Drive < ApplicationRecord

  after_initialize :defaults

  validate :start_end_dates
  belongs_to :driver


  # Returns the +Company+ for this drive or nil if the
  # +driver+ is not associated with a company.
  #
  # @return [Company | NullClass] The company of the associated driver
  def company
    driver.company
  end

  def week_nr
    self.start.to_date.cweek
  end

  def day_of_week
    I18n.l self.start, format: '%A'
  end

  def self.total_hrs
    sum('drives.end - drives.start')
  end

  def tasks
    tasks = []
    tasks << Drive.human_attribute_name(:plowed) if plowed
    tasks << Drive.human_attribute_name(:salted) if salted
    tasks << Drive.human_attribute_name(:salt_refilled) if salt_refilled
    tasks
  end

  def duration
    if has_attribute? :duration
      read_attribute(:duration)
    else
      Time.at(self.end - self.start).utc
    end
  end

  def self.by_season(season)
    where('start > ? AND start < ?', season.start_date, season.end_date)
  end

  private
  def start_end_dates
    errors.add(:end, :not_before_start) if self.end < self.start
  end

  def defaults
    self.start ||= DateTime.now if self.has_attribute? :start
    self.end ||= DateTime.now if self.has_attribute? :end
  end

end
