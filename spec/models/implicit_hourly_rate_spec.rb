require 'rails_helper'

RSpec.describe ImplicitHourlyRate do

  # We need to disable transactional specs because implicit hourly rates is based on a db view
  # which will not be populated until the transaction is committed.
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

  describe '#to_explicit_rate' do
    let(:price) { Money.new(20000, 'CHF') }
    let(:valid_from) { 1.month.ago }
    let(:valid_until){ 1.year.from_now }

    let(:base_rate) { create(:hourly_rate, company: company,
                             price: price,
                             valid_until: valid_until,
                             valid_from: valid_from,
                             customer: nil,
                             activity: nil)}
    let(:implicit_rate) { described_class.new company_id: company.id,
                                              hourly_rate_id: base_rate.id,
                                              price: price,
                                              customer_id: customer.id,
                                              activity_id: activity.id }

    subject { implicit_rate.to_explicit_rate }

    it { is_expected.to be_a HourlyRate }
    it { is_expected.not_to be_persisted }
    it { is_expected.to be_valid }
    its(:valid_from) { is_expected.to eq valid_from.to_date }
    its(:valid_until) { is_expected.to eq valid_until.to_date }
    its(:price) { is_expected.to eq price }
    its(:customer) { is_expected.to eq customer }
    its(:activity) { is_expected.to eq activity }
    its(:company) { is_expected.to eq company }
  end

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