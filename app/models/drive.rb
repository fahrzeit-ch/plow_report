# frozen_string_literal: true

# TODO: This model should be renamed to amore abstract entity so it cannot only
# represent drives but also any other tasks
class Drive < ApplicationRecord
  after_initialize :defaults

  # A drive is always done by a driver
  belongs_to :driver
  belongs_to :tour, optional: true
  belongs_to :vehicle, optional: true

  after_save :update_tour

  # A drive may have an activity that was executed during the drive
  has_one :activity_execution, dependent: :destroy
  has_one :activity, through: :activity_execution
  accepts_nested_attributes_for :activity_execution, reject_if: :all_blank

  # A Drive may be recorded on a customer but its not necessary
  belongs_to :customer, optional: true
  belongs_to :site, optional: true

  validates :end, date: { after: :start }
  validate :vehicle_same_as_tour

  # Allow to discard instead of destroy drives
  include Discard::Model
  include ChangedSince
  include TrackedViews

  extend Memoist

  scope :without_tour, -> { where(tour_id: nil) }

  attribute :separately_charged, :boolean, default: false
  validate :customer_associated_with_site

  audited associated_with: :driver

  def kept?
    discarded? && tour.kept?
  end

  def self.kept
    undiscarded.without_tour.or(Drive.where(id: undiscarded.joins(:tour).merge(Tour.undiscarded)))
  end

  # Returns the +Company+ for this drive or nil if the
  # +driver+ is not associated with a company.
  #
  # @return [Company | NilClass] The company of the associated driver
  def company
    driver.company
  end

  # Whether or not an activity value for the drives
  # activity execution is required.
  def missing_activity_value
    return false unless activity.has_value
    site.requires_value_for_ids.include?(activity.id) && activity_execution.value == 0
  end

  def week_nr
    self.start.to_date.cweek
  end

  def associated_to_as_json
    return nil unless site_id || customer_id
    customer_association.to_json
  end

  def associated_to_as_json=(json)
    assoc = CustomerAssociation.from_json json
    self.customer_association = assoc
  end

  def customer_association
    CustomerAssociation.new(customer_id, site_id)
  end

  def customer_association=(assoc)
    self.customer_id = assoc.customer_id
    self.site_id = assoc.site_id
  end

  def day_of_week
    I18n.l self.start, format: "%a"
  end

  # @return The hourly rate applicable for this drive.
  def prices
    DrivePrice.new self
  end
  memoize :prices

  def customer_name
    customer ? "#{customer.name} #{customer.first_name}" : ""
  end

  def site_name
    site ? site.display_name : ""
  end

  # returns the name of the activity performed on this drive
  def tasks
    activity.try(:name)
  end

  def duration_with_empty_drives
    duration_seconds + empty_drive_duration
  end

  # Returns the additional time of the empty drives of the tour that will
  # be applied to this drive for billing to customers
  #
  # It only returns the empty drive duration for charged
  # drives, otherwise will return 0, as the empty drive
  # time is averaged on the separately charged drives only.
  def empty_drive_duration
    if charged_separately?
      tour.try(:avg_empty_drive_time_per_site) || 0
    else
      0
    end
  end

  # Returns true if it is the first drive in a tour for
  # the associated site, or if it is explicitly flagged to
  # be charged again.
  def charged_separately?
    return true unless tour # always charge if not in a tour
    (tour.first_of_site(site_id) == self) || separately_charged
  end
  memoize :charged_separately?

  def duration_seconds
    if has_attribute? :duration
      read_attribute(:duration)
    else
      self.end - self.start
    end
  end

  # Returns the type of rate that should apply for this drive
  # Currently only none (0) and surcharge (1) is supported
  def surcharge_rate_type
    weekend? ? 1 : 0
  end

  # Returns true if start or end time is on a saturday or sunday
  def weekend?
    start.on_weekend? || read_attribute(:end).on_weekend?
  end

  # Class Methods
  class << self
    def stats
      values = Statistic.new
      drive_stats = select("EXTRACT(epoch FROM COALESCE(SUM(drives.end - drives.start), '00:00:00'::interval)) as duration,
0 as salt,
COALESCE(SUM(distance_km), cast('0' as double precision)) as distance")[0]

      values.distance = drive_stats.distance
      values.duration_seconds = drive_stats.duration_seconds
      values.activity_values = activity_value_summary
      values
    end

    def activity_value_summary
      select("activities.value_label as title, SUM(activity_executions.value) as total")
          .joins(:activity)
          .where(activities: { has_value: true })
          .group(:value_label)
          .sort_by { |item| item[:title] }
    end

    # Scope the drives by the given season
    def by_season(season)
      where("start > ? AND start < ?", season.start_date, season.end_date)
    end

    # sum the hours of all drives in the current scope
    def total_hrs
      sum("drives.end - drives.start")
    end

    # Returns the last recorded distance and activity_value used by the driver depending on the drive options.
    # There are three cases:
    #
    # @param [Driver] driver The driver to get the sugestion for
    # @param [Hash] drive_opts Drive options to match similar drives
    # @return [Float] Suggested distance for the given drive options
    def suggested_values(driver, drive_opts)
      similar_drives = Drive.where(driver: driver).similar(drive_opts)
      last_match = similar_drives.order(end: :desc).first
      {
          distance_km: last_match.try(:distance_km) || 0,
          activity_value: last_match.try(:activity_execution).try(:value) || 0
      }
    end

    # The similar method returns drives that have the same
    # activity.
    #
    # @param [Hash] drive_opts
    # @return [ActiveRecord::Relation<Drive>] Drive relation that have similar characteristics on the options
    def similar(drive_opts)
      activity_id = drive_opts[:activity_id]
      if activity_id
        joins(:activity_execution).where(activity_executions: { activity_id: activity_id })
      else
        Drive
      end
    end
  end

  private
    def vehicle_same_as_tour
      if tour&.vehicle && vehicle != tour.vehicle
        errors.add(:vehicle, :vehicle_not_sames_as_tour)
      end
    end

    def update_tour
      tour.try(:refresh_times_from_dirves)
    end

    def customer_associated_with_site
      return if customer.nil? || site.nil?
      errors.add(:associated_to_as_json, :not_associated_to_customer) if customer != site.customer
    end

    def defaults
      self.start ||= Time.current if self.has_attribute? :start
      self.end ||= Time.current if self.has_attribute? :end
    end
end
