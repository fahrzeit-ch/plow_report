# A tour combines multiple drives and tracks the overall
# time spent by a driver.
class Tour < ApplicationRecord
  include Discard::Model
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
    sorted_drives.first
  end

  # @return [Drive[]] Array of drives sorted descending by their start time
  def sorted_drives
    drives.sort_by(&:start)
  end

  # Returns the first drive associated to this
  # tour sorted by starttime
  #
  # @return [Drive | NilClass] The first drive of this tour or nil if no drive associated yet
  def last_drive
    sorted_drives.last
  end

  def end_time
    self.read_attribute(:end_time) || last_drive.try(:end)
  end

  def distance_km
    drives.sum(:distance_km)
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
    if has_attribute? :duration
      Time.at(read_attribute(:duration)).utc
    else
      Time.at(self.end_time - self.start_time).utc
    end
  end

  def duration_in_hours
    ( self.end_time - self.start_time ) / 3600.0
  end

  # Returns the duration in as string in the form HH:MM.
  # Seconds will be rounded.
  # Can show hours > 24
  #
  # @return [String] duration as text
  def duration_as_string
    seconds = duration.to_i
    minutes = (seconds / 60).round #ignore seconds
    hours = (minutes / 60) # do not round here as we will display minutes

    parts = []
    parts << "#{hours}h" if hours > 0
    parts << "#{(minutes % 60)}min"

    parts.join(' ')
  end

  # TODO: This does not belong here. Extract duration formatting
  # to some kind of TimeSpan class
  def justify(hours)
    hours.to_s.rjust(2, '0')
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
