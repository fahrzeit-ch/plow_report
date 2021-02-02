# frozen_string_literal: true

module Report
  class Renderer
    attr_accessor :company
    attr_accessor :drives

    def initialize(company, drives)
      @company = company
      @drives = drives
    end

    def render
      render_stream(build_package)
    end

    private
      # @param [Axlsx::Package] package
      def render_stream(package)
        package.use_shared_strings = true
        package.to_stream
      end

      def build_package
        Axlsx::Package.new do |xlsx_package|
          wb = xlsx_package.workbook
          styles = Styles.new(wb)
          header_builder = HeaderBuilder.new(company.activities, styles)
          row_builder = DriveRowBuilder.new(styles, header_builder.activity_index_map)

          customers_with_drives = @drives.group_by(&:customer)
          drives_without_customers = customers_with_drives.delete(nil)

          if drives_without_customers
            build_non_customer_sheet(wb, drives_without_customers, row_builder, header_builder, styles)
          end

          customers_with_drives.each do |customer, drives|
            build_customer_sheet(wb, customer, drives, row_builder, header_builder, styles)
          end
        end
      end

      def build_non_customer_sheet(wb, drives_without_customers, row_builder, header_builder, styles)
        wb.add_worksheet(name: I18n.t("reports.drives.tab_title_without_customer")) do |sheet|
          table_builder = DriveTableBuilder.new(drives_without_customers, row_builder, header_builder)

          sheet.add_row [I18n.t("reports.drives.sheet_title_without_customer")], style: [styles.h1]
          sheet.add_row
          sheet.add_row
          sheet.add_row [I18n.t("reports.drives.label_total_km"), table_builder.distance_sum_formula]
          sheet.add_row [I18n.t("reports.drives.label_total_duration"), table_builder.duration_sum_formula], style: [nil, styles.duration]
          sheet.add_row [I18n.t("reports.drives.label_total_price"), table_builder.price_sum_formula]
          sheet.add_row
          table_builder.add_to_worksheet sheet
        end
      end

      def build_customer_sheet(wb, customer, drives, row_builder, header_builder, styles)
        wb.add_worksheet(name: customer.try(:name)) do |sheet|
          table_builder = DriveTableBuilder.new(drives, row_builder, header_builder, customer)

          sheet.add_row [I18n.t("reports.drives.sheet_title_with_customer")]
          sheet.add_row ["#{customer.first_name} #{customer.name}"], style: [styles.h1]
          sheet.add_row [customer.street]
          sheet.add_row ["#{customer.zip} #{customer.city}"]
          sheet.add_row
          sheet.add_row
          sheet.add_row [I18n.t("reports.drives.label_total_km"), table_builder.distance_sum_formula]
          sheet.add_row [I18n.t("reports.drives.label_total_duration"), table_builder.duration_sum_formula], style: [nil, styles.duration]
          sheet.add_row [I18n.t("reports.drives.label_total_price"), table_builder.price_sum_formula]
          sheet.add_row
          table_builder.add_to_worksheet sheet
        end
      end
  end
end
