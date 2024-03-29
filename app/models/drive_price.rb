# frozen_string_literal: true

# Fetches and calculates the applicable prices for the given drive
#
class DrivePrice
  # [Drive]
  attr_reader :drive

  # @param [Drive] drive
  def initialize(drive)
    @drive = drive
    fetch!
  end

  def travel_expense
    if drive.charged_separately?
      @travel_expense_flat || calculate_travel_expense(@travel_expense_rate)
    else
      Money.new("0")
    end
  end

  def travel_expense_per_hour
    if drive.charged_separately?
      @travel_expense_flat || @travel_expense_rate || Money.new("0")
    else
      Money.new("0")
    end
  end

  def price
    if drive.charged_separately?
      @flat_rate || calculate_total_price(@hourly_rate)
    elsif !flat_rate?
      calculate_total_price(@hourly_rate)
    else
      Money.new("0")
    end
  end

  def price_per_hour
    if drive.charged_separately?
      @flat_rate || @hourly_rate || Money.new("0")
    elsif !flat_rate?
      @hourly_rate
    else
      Money.new("0")
    end
  end

  def flat_rate?
    !@flat_rate.nil?
  end

  def travel_expense_flat_rate?
    !@travel_expense_flat.nil?
  end

  private
    def fetch!
      load_activity_flat_rate
      load_hourly_rate
      load_travel_expense_flat_rate
      load_travel_expense_rate
    end

    def load_activity_flat_rate
      @flat_rate = drive.site
                     &.site_activity_flat_rates
                     &.find { |a| a.activity == drive.activity }
                     &.activity_fee_for_date(drive.start)
                     &.price
    end

    def load_hourly_rate
      @hourly_rate = drive.vehicle
                       &.vehicle_activity_assignments
                       &.find { |a| a.activity == drive.activity }
                       &.hourly_rate_for_date(drive.start)
                       &.price
    end

    def load_travel_expense_rate
      @travel_expense_rate = drive.vehicle
                               &.hourly_rate_for_date(drive.start)
                               &.price
    end

    def load_travel_expense_flat_rate
      @travel_expense_flat = drive.site
                               &.travel_expense_for_date(drive.start)
                               &.price
    end

    def calculate_travel_expense(rate)
      calculate_price rate, drive.empty_drive_duration
    end

    def calculate_total_price(rate)
      calculate_price rate, drive.duration_seconds
    end

    def calculate_price(rate, duration_seconds)
      cents_per_hour = rate&.fractional || 0
      hours = duration_seconds / 3600.0
      total_cents = cents_per_hour * hours
      Money.new(total_cents.round(2))
    end

end