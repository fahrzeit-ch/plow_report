# A tour combines multiple drives and tracks the overall
# time spent by a driver.
class Tour < ApplicationRecord
  include Discard::Model
  default_scope -> { kept }

  belongs_to :driver
  has_many :drives, -> { kept }, class_name: 'Drive', dependent: :nullify
  audited

  include TrackedViews

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
