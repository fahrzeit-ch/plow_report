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
        drive.start, drive.start, drive.duration, drive.site_name, drive.driver.name, drive.distance_km
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
  end
end