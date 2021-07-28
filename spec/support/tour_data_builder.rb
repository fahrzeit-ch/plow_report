# Builds sample tours using FactoryBot.
# Example usage:
# <pre>
#   sample_tours = TourDataBuilder.build do |b|
#     # Use an existing company (default: new company)
#     b.set_company(existing_company)
#     # Use an existing driver (default: new driver)
#     b.set_driver(existing_driver)
#
#     # reuse a site exactly twice per tour, meaning
#     # each site will occur 3 times per tour
#     b.set_max_repetitions(2)
#     b.set_min_repetitions(2)
#
#     # each tour will have at least one unique site
#     b.set_min_sites(2)
#     # each tour will have maximum of 3 unique sites
#     b.set_max_sites(3)
#   end
# </pre>
class TourDataBuilder
  def self.build
    builder = new
    yield(builder)
    builder.build
  end

  def set_company(company)
    @company = company
    self
  end

  # Sets the driver to use for all tours and drives
  def set_driver(driver)
    @driver = driver
    self
  end

  # Set how often a site can be reused per tour. Can not be less than min_repetitions.
  # Default: equal to value of min_repetitions
  def set_max_repetitions(n)
    raise ArgumentError.new "Can assign negative number for min_sites" if n < 0
    @max_repetitions = n
  end

  # Sets how often a site is reused per tour at least. Value > 0 means every site on
  # a tour is reused at least once.
  # Default: 0
  def set_min_repetitions(n)
    raise ArgumentError.new "Can assign negative number for min_sites" if n < 0
    @min_repetitions = n
  end

  # Set how many unique sites will be used at max per tour
  # May not be less than min sites
  # Default: value of min_sites
  def set_max_sites(n)
    raise ArgumentError.new "Can assign negative number for max_sites" if n < 0
    @max_sites = n
  end

  # Set how many unique sites will be used at least per tour
  # Default 1
  def set_min_sites(n)
    raise ArgumentError.new "Can assign negative number for min_sites" if n < 0
    @min_sites = n
  end

  # set how many tours will be created
  def set_number_of_tours(n)
    @number_of_tours = n
    self
  end

  # sets the date range that the tours will be created within.
  def set_date_range(start_date, end_date)
    raise ArgumentError.new "Start_date can not be after end_date" if start_date > end_date
    @start_date = start_date
    @end_date = end_date
    self
  end

  def build
    tours = []
    num_days_in_range = (start_date..end_date).count
    increment = num_days_in_range / number_of_tours
    day = start_date
    number_of_tours.times do
      tours << create_tour(day)
      day = day + increment.days
    end
    tours
  end

  private
    def create_tour(day)
      start_time = day
      end_time = day + 1.hour
      tour = FactoryBot.create(:tour, driver: driver, start_time: start_time, end_time: end_time)

      number_of_sites = rand(min_sites..max_sites)
      number_of_sites.times do |i|
        amount = 1 + rand(min_repetitions..max_repetitions)
        FactoryBot.create_list(:drive, amount, site: sites[i], customer_id: sites[i].customer_id, tour: tour, start: start_time, end: end_time, driver: driver)
      end
      tour
    end

    def max_sites
      [(@max_sites || 0), min_sites].max
    end

    def min_sites
      @min_sites || 1
    end

    def max_repetitions
      [(@max_repetitions || 0), min_repetitions].max
    end

    def min_repetitions
      @min_repetitions || 0
    end

    def start_date
      @start_date || Season.previous.start_date
    end

    def end_date
      @end_date || Season.previous.start_date
    end

    def customer
      @customer ||= FactoryBot.create(:customer, client_of: company)
    end

    def sites
      @sites ||= FactoryBot.create_list(:site, max_sites, customer: customer)
    end

    def driver
      @driver ||= FactoryBot.create :driver, company: company
    end

    def company
      @company ||= FactoryBot.create :company
    end

    def number_of_tours
      @number_of_tours || 1
    end
end