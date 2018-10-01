class Drive < ApplicationRecord

  after_initialize :defaults
  before_validation :check_salt_amount

  validates :salt_amount_tonns, numericality: { greater_than: 0 }, if: :salt_refilled
  validate :start_end_dates
  belongs_to :driver
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

  def day_of_week
    I18n.l self.start, format: '%A'
  end

  # Get the tasks (drive options) as an Array with translated option names
  def tasks
    tasks = []
    tasks << Drive.human_attribute_name(:plowed) if plowed
    tasks << Drive.human_attribute_name(:salted) if salted
    tasks << Drive.human_attribute_name(:salt_refilled) if salt_refilled
    tasks
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
    "#{justify(hours)}h #{justify((minutes % 60))}min"
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

    # Scope the drives by the given season
    def by_season(season)
      where('start > ? AND start < ?', season.start_date, season.end_date)
    end

    # sum the hours of all drives in the current scope
    def total_hrs
      sum('drives.end - drives.start')
    end

    # Returns the last recorded distance and salt amount (if any) of the given driver depending on the drive options.
    # There are three cases:
    #
    # * salt_refilled and not plowed or salted
    # * salt_refilled and plowed or salted
    # * salt_not_refilled
    #
    # salt_amount_tonns will allways return value of last refill, ignoring other options
    #
    # @param [Driver] driver The driver to get the sugestion for
    # @param [Hash] drive_opts Drive options to match similar drives
    # @return [Float] Suggested distance for the given drive options
    def suggested_values(driver, drive_opts)
      similar_drives = select(:distance_km, :salt_amount_tonns).where( driver: driver).similar(drive_opts)

      latest_refill = select(:salt_amount_tonns)
                          .where(driver: driver, salt_refilled: drive_opts.fetch(:salt_refilled, false))
                          .order(end: :desc).first

      last_match = similar_drives.order(end: :desc).first

      salt_amount = latest_refill ? latest_refill.salt_amount_tonns : 0
      distance = last_match ? last_match.distance_km : 0

      { salt_amount_tonns: salt_amount, distance_km: distance }
    end

    # The similar method returns drives that have similar tasks and
    # therefore could probably have the same distance.
    # Similarity is checked in three groups:
    #
    # * salt refilled and not plowed or salted
    # * salt refilled and plowed or salted
    # * salt not refilled
    #
    # The drive_opts param can contain the following keys:
    #
    # * salt_refilled
    # * plowed
    # * salted
    #
    # @param [Hash] drive_opts
    # @return [ActiveRecord::Relation<Driver>] Driver relation that have similar characteristics on the options
    def similar(drive_opts)
      salt_refilled = drive_opts.fetch(:salt_refilled, false)
      pos = drive_opts.fetch(:salted, false) || drive_opts.fetch(:plowed, false)
      pos_query = "#{pos ? '' : 'NOT '}(drives.plowed OR drives.salted)"
      where(salt_refilled: salt_refilled).where(pos_query)
    end
  end

  def self.define_drive_type_accessors
    %i[plowed salted salt_refilled].each do |type|
      define_method "#{type}=" do |value|
        val = ActiveRecord::Type::Boolean.new.cast(value)
        activities[type.to_s] = val
      end
      define_method type do
        activities[type]
      end
    end
  end


  private

  def check_salt_amount
    self.salt_amount_tonns = 0 unless salt_refilled
  end

  def start_end_dates
    errors.add(:end, :not_before_start) if self.end < self.start
  end

  def defaults
    self.start ||= DateTime.now if self.has_attribute? :start
    self.end ||= DateTime.now if self.has_attribute? :end
  end

end
