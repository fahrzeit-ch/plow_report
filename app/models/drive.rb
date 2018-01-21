class Drive < ApplicationRecord

  def defaults
    @start ||= DateTime.now
    @end ||= DateTim.now
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
end
