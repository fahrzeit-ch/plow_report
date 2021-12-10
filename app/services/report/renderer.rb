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
        ws_name = get_unique_worksheet_name_for_customer wb, customer
        wb.add_worksheet(name: ws_name) do |sheet|
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

      # Retrieve a unique name for the worksheet for this customer
      #
      # If the name already exists, a number postfix will be added and incremented until a unique
      # name is found.
      def get_unique_worksheet_name_for_customer(wb, customer)
        name = [customer.try(:first_name), customer.try(:name)].join(',')
        idx = 1
        if wb.worksheets.any? { |ws| ws.name == name }
          new_name = "#{name} #{idx}"
          while wb.worksheets.any? { |ws| ws.name == new_name }
            idx += 1
          end
          name = new_name
        end
        name
      end
  end
end
