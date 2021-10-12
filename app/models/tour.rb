# frozen_string_literal: true

# A tour combines multiple drives and tracks the overall
# time spent by a driver.
class Tour < ApplicationRecord
  extend Memoist
  include Discard::Model
  include ChangedSince

  attribute :full_validation, :boolean, default: false

  belongs_to :driver
  belongs_to :vehicle, optional: true
  has_many :drives, -> { kept.order(start: :desc) }, class_name: "Drive", dependent: :nullify
  has_one :reasonability_check_warning, as: :record, dependent: :destroy

  audited

  validates :start_time, presence: true
  validates :end_time, date: { after: :start_time }, allow_nil: true
  validate :start_time_not_after_first_drive
  validate :end_time_not_before_last_drive, if: :full_validation
  validate :drive_time_not_more_than_tour_time, if: :full_validation
  validate :vehicle_same_company_as_driver

  before_validation :set_default_start_time
  after_update :update_children
  after_save_commit :perform_reasonability_checks

  # Returns the first drive associated to this
  # tour sorted by starttime
  #
  # @return [Drive | NilClass] The first drive of this tour or nil if no drive associated yet
  def first_drive
    drives.last
  end

  # Returns a list of drives that need to be checked by the user
  # because they have missing values
  def invalid_drives
    all_drives = drives.includes(activity_execution: :activity, site: :requires_value_for).to_a
    all_invalid_drives = all_drives.to_a.select { |d| d.missing_activity_value }
    all_invalid_drives.reject { |d| has_corresponding_valid_drive(all_drives, d) }
  end
  memoize :invalid_drives

  # Returns the first drive associated to this
  # tour sorted by starttime
  #
  # @return [Drive | NilClass] The first drive of this tour or nil if no drive associated yet
  def last_drive
    drives.first
  end

  # Returns the average travel time per charged site
  #
  def avg_empty_drive_time_per_site
    if charged_sites_count == 0
      empty_drive_time
    else
      empty_drive_time / charged_sites_count
    end
  end

  # Returns the first drive within this tour
  # with the given site
  def first_of_site(site_id)
    drives.to_a.reverse.find { |d| d.site_id == site_id }
  end

  def end_time
    self.read_attribute(:end_time) || last_drive.try(:end)
  end

  def distance_km
    drives.sum(:distance_km)
  end

  def empty_drive_time
    @empty_drive_time ||= duration_seconds - drives_duration
  end

  def drives_count
    @drives_count ||= drives.size
  end

  # @return [Hash] Number of occurrences for each site, where the keys are the ids of the site
  def sites_occurrences
    @sites_count ||= drives.pluck(:site_id).tally
  end

  # @return [Numeric] The number of unique sites in this tour
  def charged_sites_count
    drives.to_a.select { |d| d.charged_separately? }.length
  end

  def drives_duration
    ActiveSupport::Duration.seconds(drives.unscope(:order).stats.duration_seconds) || 0
  end

  def empty_drive_percentage
    100 - drives_percentage
  end

  def drives_percentage
    if self.finished?
      100 / duration_seconds * drives_duration
    else
      0
    end
  end

  def week_nr
    self.start_time.to_date.cweek
  end

  def day_of_week
    I18n.l self.start_time, format: "%a"
  end

  # The duration is loaded from attribute (in case it was calculated in the sql query). If
  # the attribute is not defined, it is calculated on the fly.
  #
  # @return [Time] the duration of the drive
  def duration
    Time.at(duration_seconds).utc
  end

  def active?
    !self.end_time
  end

  def finished?
    !active?
  end


  def duration_seconds
    if active?
      0
    else
      self.end_time - self.start_time
    end
  end

  def refresh_times_from_dirves
    reload
    return unless drives.any?
    drives_start_time = first_drive.start
    drives_end_time = last_drive.end

    if self.start_time > drives_start_time
      self.start_time = drives_start_time
    end

    if self.end_time < drives_end_time
      self.end_time = drives_end_time
    end
    self.save
  end

  class << self
    # Scope the drives by the given season
    def by_season(season)
      where("start_time > ? AND start_time < ?", season.start_date, season.end_date)
    end
  end

  private

    def has_corresponding_valid_drive(all_drives, d)
      all_drives.any? { |d1| d.id != d1.id && d.site_id == d1.site_id && d.activity.id == d1.activity.id && !d1.missing_activity_value }
    end

    def update_children
      changes = {}
      changes[:vehicle_id] = self.vehicle_id if saved_change_to_attribute?(:vehicle_id)
      changes[:driver_id] = self.driver_id if saved_change_to_attribute?(:driver_id)
      unless changes.blank?
        drives.update_all(changes)
      end
    end

    def drive_time_not_more_than_tour_time
      if duration_seconds - drives_duration < 0
        errors.add(:base, :total_time_gt_tour_time)
      end
    end

    def end_time_not_before_last_drive
      if last_drive&.end && (last_drive.end > end_time)
        errors.add(:end_time, :before_last_drive)
      end
    end

    def vehicle_same_company_as_driver
      if (vehicle && driver) && (vehicle.company_id != driver.company_id)
        errors.add(:vehicle, :not_found)
      end
    end

    def set_default_start_time
      self.start_time ||= first_drive.try(:start)
    end

    def start_time_not_after_first_drive
      if start_time && first_drive && first_drive.start < start_time
        errors.add(:start_time, :after_fist_drive)
      end
    end

    def perform_reasonability_checks
      ReasonabilityCheckJob.perform_later(self.id)
    end
end
