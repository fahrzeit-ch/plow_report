class Drive < ApplicationRecord

  validate :start_end_dates

  def defaults
    @start ||= DateTime.now
    @end ||= DateTime.now
  end

  def week_nr
    self.start.to_date.cweek
  end

  def day_of_week
    self.start.strftime("%A")
  end

  def tasks
    tasks = []
    tasks << I18n.t('active_record.attributes.drive.task.plow') if plowed
    tasks << I18n.t('active_record.attributes.drive.task.salt') if salted
    tasks << I18n.t('active_record.attributes.drive.task.refill_salt') if salt_refilled
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
