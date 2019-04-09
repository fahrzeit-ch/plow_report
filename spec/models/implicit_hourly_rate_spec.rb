require 'rails_helper'

RSpec.describe ImplicitHourlyRate do
  self.use_transactional_tests = false

  def clear_all
    ActiveRecord::Base.connection.execute('delete from hourly_rates')
    ActiveRecord::Base.connection.execute('delete from customers')
    ActiveRecord::Base.connection.execute('delete from activities')
    ActiveRecord::Base.connection.execute('delete from companies')
  end

  let(:company) { create(:company) }
  let(:customer) { create(:customer, company_id: company.id) }
  let(:activity) { create(:activity, company: company) }
  let(:rate) { create(:hourly_rate, activity: activity, customer: nil, company: company) }

  before do
    clear_all
    rate
  end

  after { clear_all }
  subject { ImplicitHourlyRate.first }

  it { is_expected.to be_readonly }

  xdescribe 'performance (Skipped because takes quire some time to run)' do
    include RSpec::Benchmark::Matchers

    let(:amount) { 200 }

    before(:all) do
      puts 'clearing database'
      clear_all
      puts 'importing test data'
      `RAILS_ENV=test bundle exec rails db < #{Rails.root.join(*%w(spec factories hourly_rates_test_dataset_200_comp.sql))}`

      @sample_company_id = Company.limit(50).last.id
      @sample_activity_id = Activity.where(company_id: @sample_company_id).first.id
    end

    it 'loads fast for company scope' do
      expect {
        ImplicitHourlyRate.where(company_id: @sample_company_id).all
      }.to perform_under(50).ms.sample(10).times
    end

    it 'loads very fast when company and activity given' do
      expect {
        ImplicitHourlyRate.where(company_id: @sample_company_id, activity_id: @sample_activity_id).all
      }.to perform_under(50).ms.sample(10).times
    end
  end
end