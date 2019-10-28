module Report
  class Styles
    attr_accessor :header
    attr_accessor :header_vertical
    attr_accessor :date
    attr_accessor :duration
    attr_accessor :time
    attr_accessor :h1
    attr_accessor :h2
    attr_accessor :checked

    # @param [Axlsx::Workbook] workbook
    def initialize(workbook)
      @workbook = workbook
      build_styles
    end

    def build_styles
      @h1 = styles.add_style(sz: 15, b: true, u: true)
      @h1 = styles.add_style(sz: 13, b: true, u: true)

      @header = styles.add_style(bg_color: '1a6ba2', fg_color: 'FF', b: true)
      @header_vertical = styles.add_style(b: true, alignment: { textRotation: 90 }, bg_color: '1a6ba2', fg_color: 'FF')

      @time = styles.add_style format_code: 'hh:mm'
      @duration = styles.add_style format_code: '[h]:mm'
      @date = Axlsx::STYLE_DATE
      @checked = styles.add_style alignment: { horizontal: :center }
    end

    def styles
      @workbook.styles
    end
  end
end