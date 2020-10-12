# A tour combines multiple drives and tracks the overall
# time spent by a driver.
class Tour < ApplicationRecord
  include Discard::Model
  include ChangedSince
  default_scope -> { kept }

  belongs_to :driver
  has_many :drives, -> { kept.order(start: :desc) }, class_name: 'Drive', dependent: :nullify
  audited

  validates :start_time, presence: true
  validates :end_time, date: { after: :start_time }, allow_nil: true
  validate :start_time_not_after_first_drive

  before_validation :set_default_start_time

  # Returns the first drive associated to this
  # tour sorted by starttime
  #
  # @return [Drive | NilClass] The first drive of this tour or nil if no drive associated yet
  def first_drive
    drives.last
  end

  # Returns the first drive associated to this
  # tour sorted by starttime
  #
  # @return [Drive | NilClass] The first drive of this tour or nil if no drive associated yet
  def last_drive
    drives.first
  end

  def avg_empty_drive_time_per_site
    if drives_count == 0
      empty_drive_time
    else
      empty_drive_time / drives_count
    end
  end

  def end_time
    self.read_attribute(:end_time) || last_drive.try(:end)
  end

  def distance_km
    drives.sum(:distance_km)
  end

  def empty_drive_time
    @empty_drive_time ||= (self.end_time - self.start_time).seconds - drives_duration
  end

  def drives_count
    @drives_count ||= drives.size
  end

  def drives_duration
    ActiveSupport::Duration.seconds(drives.unscope(:order).stats.duration_seconds)
  end

  def empty_drive_percentage
    100 - drives_percentage
  end

  def drives_percentage
    100 / duration_seconds * drives_duration
  end

  def week_nr
    self.start_time.to_date.cweek
  end

  def day_of_week
    I18n.l self.start_time, format: '%a'
  end

  # The duration is loaded from attribute (in case it was calculated in the sql query). If
  # the attribute is not defined, it is calculated on the fly.
  #
  # @return [Time] the duration of the drive
  def duration
    Time.at(duration_seconds).utc
  end

  def duration_seconds
    self.end_time - self.start_time
  end

  class << self
    # Scope the drives by the given season
    def by_season(season)
      where('start_time > ? AND start_time < ?', season.start_date, season.end_date)
    end
  end

  private

  def set_default_start_time
    self.start_time ||= first_drive.try(:start)
  end

  def start_time_not_after_first_drive
    if start_time && first_drive && first_drive.start < start_time
      errors.add(:start_time, :after_fist_drive)
    end
  end

end