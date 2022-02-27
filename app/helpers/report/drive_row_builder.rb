# frozen_string_literal: true

module Report
  class DriveRowBuilder
    ACTIVITY_EXECUTION_INDICATOR_VALUE = "x"

    # @param [Report::Styles] styles
    # @param [Hash] activity_index_map
    def initialize(styles, activity_index_map)
      @activity_index_map = activity_index_map
      @styles = styles
    end

    # @param [Drive] drive
    def get_hourly_rate(drive)
      if drive.prices.flat_rate?
        I18n.t('reports.drives.flat_rate')
      else
        drive.prices.price_per_hour.amount
      end
    end

    # @param [Drive] drive
    def get_travel_expense_rate(drive)
      if drive.prices.travel_expense_flat_rate?
        I18n.t('reports.drives.flat_rate')
      elsif drive.charged_separately?
        drive.prices.travel_expense_per_hour.amount
      end
    end

    # @param [Drive] drive
    def columns_for(drive)
      columns = [
        drive.start,
        drive.start,
        seconds_to_excel_time(drive.duration_seconds),
        drive.site_name,
        drive.driver.name,
        drive.vehicle&.name,
        drive.distance_km,
        get_hourly_rate(drive),
        get_price(drive)
      ]
      return columns unless drive.activity_execution

      ae = drive.activity_execution
      idx = @activity_index_map[ae.activity_id]
      values = [ACTIVITY_EXECUTION_INDICATOR_VALUE]
      values << ae.value if ae.activity.has_value?
      columns.insert(idx, *values)
    end

    def empty_drive_columns_for(drive)
      [ nil,
        nil,
        seconds_to_excel_time(drive.empty_drive_duration),
        I18n.t("reports.drives.label_empty_drive_time"),
        nil,
        nil,
        nil,
        get_travel_expense_rate(drive),
        get_travel_expense(drive)]
    end

    def styles
      [@styles.date, @styles.time, @styles.duration]
    end

    # @param [Drive] drive
    def get_price(drive)
      skip_price = (drive.prices.flat_rate? && !drive.charged_separately?)
      skip_price ? nil : drive.prices.price.amount
    end

    # @param [Drive] drive
    def get_travel_expense(drive)
      skip_price = (drive.prices.travel_expense_flat_rate? && !drive.charged_separately?)
      skip_price ? nil : drive.prices.travel_expense.amount
    end

    private
      def seconds_to_excel_time(duration)
        seconds_per_day = 86_400.0
        duration.to_f / seconds_per_day
      end
  end
end
