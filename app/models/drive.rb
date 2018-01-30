class Drive < ApplicationRecord

  after_initialize :defaults

  validate :start_end_dates
  belongs_to :driver

  def defaults
    self.start ||= DateTime.now
    self.end ||= DateTime.now
  end

  def week_nr
    self.start.to_date.cweek
  end

  def day_of_week
    I18n.l self.start, format: '%A'
  end

  def tasks
    tasks = []
    tasks << Drive.human_attribute_name(:plowed) if plowed
    tasks << Drive.human_attribute_name(:salted) if salted
    tasks << Drive.human_attribute_name(:salt_refilled) if salt_refilled
    tasks
  end

  def duration
    Time.at(self.end - self.start).utc
  end

  def self.by_season(season)
    where('start > ? AND start < ?', season.start_date, season.end_date)
  end

  private
  def start_end_dates
    errors[:end] << 'not_before_start' if self.end < self.start
  end
end
