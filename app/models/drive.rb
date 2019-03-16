# TODO: This model should be renamed to amore abstract entity so it cannot only
# represent drives but also any other tasks
class Drive < ApplicationRecord

  after_initialize :defaults
  validate :start_end_dates

  # A drive is allways done by a driver
  belongs_to :driver

  # A drive may have an activity that was executed during the drive
  has_one :activity_execution, dependent: :destroy
  has_one :activity, through: :activity_execution
  accepts_nested_attributes_for :activity_execution, reject_if: :all_blank

  # A Drive may be recorded on a customer but its not necessary
  # TODO: Refactor to only allow site relation and create a transition to move existing records to new concept
  belongs_to :customer, optional: true
  belongs_to :site, optional: true
  validate :customer_associated_with_site

  audited associated_with: :driver

  include TrackedViews

  # Returns the +Company+ for this drive or nil if the
  # +driver+ is not associated with a company.
  #
  # @return [Company | NilClass] The company of the associated driver
  def company
    driver.company
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
    I18n.l self.start, format: '%a'
  end

  def customer_name
    customer ? customer.name : ''
  end

  def site_name
    site ? site.name : ''
  end

  # Get the tasks (drive options) as an Array with translated option names
  def tasks
    activity.try(:name)
  end

  # The duration is loaded from attribute (in case it was calculated in the sql query). If
  # the attribute is not defined, it is calculated on the fly.
  #
  # @return [Time] the duration of the drive
  def duration
    if has_attribute? :duration
      Time.at(read_attribute(:duration)).utc
    else
      Time.at(self.end - self.start).utc
    end
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
      drive_stats = select("EXtRACT(epoch FROM COALESCE(SUM(drives.end - drives.start), '00:00:00'::interval)) as duration,
0 as salt,
COALESCE(SUM(distance_km), cast('0' as double precision)) as distance")[0]

      values.distance = drive_stats.distance
      values.duration_as_string = drive_stats.duration_as_string
      values.activity_values = activity_value_summary
      values
    end

    def activity_value_summary
      select('activities.value_label as title, SUM(activity_executions.value) as total').joins(:activity).group(:value_label)
    end

    # Scope the drives by the given season
    def by_season(season)
      where('start > ? AND start < ?', season.start_date, season.end_date)
    end

    # sum the hours of all drives in the current scope
    def total_hrs
      sum('drives.end - drives.start')
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
    # @return [ActiveRecord::Relation<Driver>] Driver relation that have similar characteristics on the options
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

  def customer_associated_with_site
    return if customer.nil? || site.nil?
    errors.add(:associated_to_as_json, :not_associated_to_customer) if customer != site.customer
  end

  def start_end_dates
    errors.add(:end, :not_before_start) if self.end < self.start
  end

  def defaults
    self.start ||= DateTime.now if self.has_attribute? :start
    self.end ||= DateTime.now if self.has_attribute? :end
  end

end
