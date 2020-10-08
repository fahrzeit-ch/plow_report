module Report
  class DriveRowBuilder
    ACTIVITY_EXECUTION_INDICATOR_VALUE = 'x'

    # @param [Report::Styles] styles
    # @param [Hash] activity_index_map
    def initialize(styles, activity_index_map)
      @activity_index_map = activity_index_map
      @styles = styles
    end

    # @param [Drive] drive
    def columns_for(drive)
      columns = [
        drive.start, drive.start, seconds_to_excel_time(drive.duration_with_empty_drives), drive.site_name, drive.driver.name, drive.distance_km, drive.hourly_rate, get_price(drive)
      ]
      return columns unless drive.activity_execution

      ae = drive.activity_execution
      idx = @activity_index_map[ae.activity_id]
      values = [ACTIVITY_EXECUTION_INDICATOR_VALUE]
      values << ae.value if ae.activity.has_value?
      columns.insert(idx, *values)
    end

    def styles
      [@styles.date, @styles.time, @styles.duration]
    end

    def get_price(drive)
      if drive.hourly_rate
        (drive.hourly_rate.amount * (drive.duration_seconds / 3600.0)).round(2)
      end
    end

    private

    def seconds_to_excel_time(duration)
      seconds_per_day = 86_400.0
      duration.to_f/seconds_per_day
    end
  end
end