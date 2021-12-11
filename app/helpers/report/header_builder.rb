# frozen_string_literal: true

module Report
  # Builds header columns a drive table.
  class HeaderBuilder
    attr_reader :activity_index_map

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

    def column_widths
      @fixed_headers.map { :auto } + @activity_headers.map { 6 }
    end

    def column_name_for(attr, activity_id = nil)
      if activity_id
        column_name_for_activity(attr, activity_id)
      else
        @fixed_headers[Report::FIXED_COLUMNS.index(attr)]
      end
    end

    def column_name_for_activity(attr, activity_id)
      case attr
      when :name
        @activities.to_a.first { |a| a.id == activity_id }.name
      when :value, :value_label
        @activities.to_a.first { |a| a.id == activity_id }.value_label
      else
        raise "Activity for id #{activity_id} not found."
      end
    end

    private

      def unique_name_for(original_name, others)
        idx = 1
        if others.any?(original_name)
          new_name = "#{original_name} #{idx}"
          while others.any?(new_name)
            idx += 1
          end
          new_name
        else
          original_name
        end

      end

      def build_activity_headers
        idx = @fixed_headers.length

        activity_headers = []
        @activities.each do |activity|
          @activity_index_map[activity.id] = idx
          idx += 1

          activity_headers << unique_name_for(activity.name, activity_headers)
          if activity.has_value?
            activity_headers << unique_name_for(activity.value_label, activity_headers)
            idx += 1
          end
        end
        activity_headers
      end

      def build_fixed_headers
        [
            I18n.t("reports.drives.drive_date_title"),
            I18n.t("reports.drives.drive_start_time_title"),
            I18n.t("reports.drives.drive_duration_title"),
            I18n.t("reports.drives.drive_site_title"),
            I18n.t("reports.drives.drive_driver_title"),
            I18n.t("reports.drives.drive_distance_title"),
            I18n.t("reports.drives.drive_hourly_rate"),
            I18n.t("reports.drives.drive_total_price")
        ]
      end
  end
end
