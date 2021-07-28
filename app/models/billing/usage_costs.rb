class Billing::UsageCosts

  # @param [Float] base_price
  # @param [Float] discount_per_day The discount for each day used in percent as a value between 0 and 1
  # @param [Integer] company_id The company id to get the Usage cost for
  # @param [Season] season
  def initialize(base_price, discount_per_day, company_id, season)
    raise ArgumentError.new "base_price must be > 0" if base_price <= 0
    raise ArgumentError.new "discount_per_day must not be negative" if discount_per_day < 0
    raise ArgumentError.new "discount_per_day must be less than 1" if discount_per_day >= 1

    raise ArgumentError.new "company_id must nut be nil" unless company_id
    raise ArgumentError.new "season must respond to start_date and end_date" unless season.respond_to?(:start_date) & season.respond_to?(:end_date)

    @base_price = base_price
    @discount_per_day = discount_per_day
    @company_id = company_id
    @season = season
  end

  def total_cost
    calculate(total_days, avg_number_of_sites_per_day, @base_price, @discount_per_day)
  end

  def avg_number_of_sites_per_day
    return 0 if day_reports.sum(&:nr_of_drives) == 0
    total_days / day_reports.sum(&:nr_of_drives)
  end

  def total_days
    day_reports.length
  end

  def day_reports
    @day_reports ||= Billing::DailyUsageReport
                       .where(company_id: @company_id)
                       .between(@season.start_date, @season.end_date)
  end

  private

    def calculate(number_of_days, avg_objects_per_day, p0, discount)
      p0 * avg_objects_per_day * get_factor(discount, number_of_days)
    end

    def get_factor(discount, total_days, day = 0)
      if day < total_days
        (1 - discount) ** day + get_factor(discount, total_days, (day + 1))
      else
        0
      end
    end
end