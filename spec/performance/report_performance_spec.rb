require 'rails_helper'
require 'support/axlsx_shared_context'

RSpec.describe 'Report Performance', type: :view do
  include RSpec::Benchmark::Matchers
  self.use_transactional_tests = false

  def clear_all
    ActiveRecord::Base.connection.execute('delete from activity_executions')
    ActiveRecord::Base.connection.execute('delete from drives')
    ActiveRecord::Base.connection.execute('delete from drivers')
    ActiveRecord::Base.connection.execute('delete from hourly_rates')
    ActiveRecord::Base.connection.execute('delete from customers')
    ActiveRecord::Base.connection.execute('delete from activities')
    ActiveRecord::Base.connection.execute('delete from companies')
  end
  after(:all) { clear_all }

  before(:all) do
    puts 'clearing database'
    clear_all
    puts 'importing large price rate set'
    `RAILS_ENV=test bundle exec rails db < #{Rails.root.join(*%w(spec factories hourly_rates_test_dataset_200_comp.sql))}`

    @sample_company = Company.limit(50).last
    driver = create(:driver, company: @sample_company)

    puts 'building regular amount of drives'
    customers = @sample_company.customers.pluck(:id)
    activities = @sample_company.activities.pluck(:id)

    customers.each do |cust|
      activities.each do |act|
        Drive.create driver: driver, activity_execution_attributes: {activity_id: act}, customer_id: cust, start: 1.hour.ago, end: 2.minutes.ago
      end
    end
  end

  describe 'company/drives/index.xlsx.axlsx' do
    include_context 'axlsx'

    it 'performs in some amount of time...' do
      Rails.logger.level = :ERROR
      expect {
        scope = @sample_company.drives
                    .includes(:driver, :activity_execution, :activity, :site, :customer)
        @drives = scope.order(start: :desc)
        wb = render_template current_company: @sample_company
      }.to perform_under(5).sec.sample(3).times
    end
  end


end