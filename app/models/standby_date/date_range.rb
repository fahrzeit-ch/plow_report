class StandbyDate
  class DateRange
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment

    attr_accessor :start_date
    attr_accessor :end_date
    attr_accessor :driver_id

    validate :end_date_gt_start_date

    def initialize(attributes={})
      @start_date = Date.current
      @end_date = Date.current
      assign_attributes attributes
    end

    def save
      if valid?
        StandbyDate.from_range start_date, end_date, driver_id
      else
        false
      end
    end

    def start_date
      @start_date.is_a?(Date) ? @start_date : Date.parse(@start_date)
    end

    def end_date
      @end_date.is_a?(Date) ? @end_date : Date.parse(@end_date)
    end

    private
    def end_date_gt_start_date
      errors.add(:end_date, :must_be_greater_than_start) if end_date < start_date
    end
  end
end