module Report

  # Builds header columns a drive table.
  class HeaderBuilder

    attr_reader :activity_index_map
    FIXED_COLUMNS = %i[date start driver duration distance].freeze

    # @param [Activities] activities
    # @param [Report::Styles] styles
    def initialize(activities, styles)
      @activities = activities
      @activity_index_map = {}

      @styles = styles

      @fixed_headers = build_fixed_headers
      @activity_headers = build_activity_headers
    end

    def columns
      @fixed_headers + @activity_headers
    end

    def styles
      @fixed_headers.map { @styles.header } + @activity_headers.map { @styles.header_vertical }
    end

    def column_name_for(attr, activity_id=nil)
      if activity_id
        column_name_for_activity(attr, activity_id)
      else
        @fixed_headers[FIXED_COLUMNS.index(attr)]
      end
    end

    def column_name_for_activity(attr, activity_id)
      case attr
      when :name
        @activities.to_a.first {|a| a.id == activity_id }.name
      when :value, :value_label
        @activities.to_a.first {|a| a.id == activity_id }.value_label
      else
        raise "Activity for id #{activity_id} not found."
      end
    end

    private

    def build_activity_headers
      idx = @fixed_headers.length

      @activities.flat_map do |activity|
        @activity_index_map[activity.id] = idx
        idx += 1

        res = [activity.name]
        if activity.has_value?
          res << activity.value_label
          idx += 1
        end

        res
      end
    end

    def build_fixed_headers
      [
          I18n.t('reports.drives.drive_date_title'),
          I18n.t('reports.drives.drive_start_time_title'),
          I18n.t('reports.drives.drive_duration_title'),
          I18n.t('reports.drives.drive_driver_title'),
          I18n.t('reports.drives.drive_distance_title')
      ]
    end
  end
end