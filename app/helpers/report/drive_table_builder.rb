module Report
  class DriveTableBuilder

    HEADER_HEIGHT = 120

    def initialize(drives, row_builder, header_builder, customer=nil)
      @rb = row_builder
      @hb = header_builder
      @drives = drives
      @customer = customer

      @last_row = nil
      @title_row = nil
      @table = nil
    end

    attr_reader :table
    attr_reader :last_row
    attr_reader :title_row

    def add_to_worksheet(ws)
      @title_row = ws.add_row @hb.columns, style: @hb.styles, height: HEADER_HEIGHT
      return if @drives.empty?

      @drives.each do |drive|
        @last_row = ws.add_row @rb.columns_for(drive), style: @rb.styles, widths: @hb.column_widths
      end

      @table = ws.add_table table_ref, name: table_name
    end

    def table_name
      @customer ? "Table#{@customer.id}" : "TableDrives"
    end

    def table_ref
      "#{@title_row.cells.first.r}:#{Axlsx::cell_r(@title_row.cells.last.index, @last_row.row_index)}"
    end

    def distance_sum_formula
      "=SUM(#{table_name}[#{@hb.column_name_for(:distance)}])"
    end

    def duration_sum_formula
      "=SUM(#{table_name}[#{@hb.column_name_for(:duration)}])"
    end

  end
end