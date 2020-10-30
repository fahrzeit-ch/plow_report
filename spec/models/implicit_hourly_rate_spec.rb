# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImplicitHourlyRate do
  # We need to disable transactional specs because implicit hourly rates is based on a db view
  # which will not be populated until the transaction is committed.
  self.use_transactional_tests = false

  def clear_all
    ActiveRecord::Base.connection.execute("delete from hourly_rates")
    ActiveRecord::Base.connection.execute("delete from customers")
    ActiveRecord::Base.connection.execute("delete from activities")
    ActiveRecord::Base.connection.execute("delete from companies")
  end
  after(:all) { clear_all }

  let(:company) { create(:company) }
  let(:customer) { create(:customer, company_id: company.id) }
  let(:activity) { create(:activity, company: company) }
  let(:rate) { create(:hourly_rate, activity: activity, customer: nil, company: company) }

  describe "readonly" do
    subject { ImplicitHourlyRate.new }

    it { is_expected.to be_readonly }
  end

  describe "#to_explicit_rate" do
    before do
      clear_all
      rate
    end

    after { clear_all }

    let(:price) { Money.new(20000, "CHF") }
    let(:valid_from) { 1.month.ago }
    let(:valid_until) { 1.year.from_now }

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

  describe "scopes" do
    describe "#best_matches" do
      let(:hourly_rates) { [] }
      subject { described_class.best_matches(hourly_rates) }


      context "explicits only" do
        let(:hourly_rates) { [
            # base rate
            ImplicitHourlyRate.new(activity_id: 1, customer_id: nil, inheritance_level: 0),
            ImplicitHourlyRate.new(activity_id: 2, customer_id: nil, inheritance_level: 0)
        ]}

        its(:count) { is_expected.to eq 2 }
      end

      context "nil" do
        let(:hourly_rates) { nil }
        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context "same target different inheritance levels" do
        let(:implicit) { ImplicitHourlyRate.new(activity_id: 1, customer_id: nil, inheritance_level: 1) }
        let(:explicit) { ImplicitHourlyRate.new(activity_id: 1, customer_id: nil, inheritance_level: 0) }
        let(:hourly_rates) {
          [
              implicit, explicit
          ]
        }

        its(:count) { is_expected.to eq 1 }
        it "returns the hourly rate" do
          expect(subject[0]).to eq explicit
        end
      end

      context "different scopes same level" do
        let(:scope1) { ImplicitHourlyRate.new(activity_id: 1, customer_id: nil, inheritance_level: 1) }
        let(:scope2) { ImplicitHourlyRate.new(activity_id: 2, customer_id: 1, inheritance_level: 1) }
        let(:scope3) { ImplicitHourlyRate.new(activity_id: 2, customer_id: 2, inheritance_level: 1) }

        let(:hourly_rates) { [scope1, scope2, scope3] }

        its(:count) { is_expected.to eq 3 }

        it { is_expected.to include(scope1) }
        it { is_expected.to include(scope2) }
        it { is_expected.to include(scope3) }
      end

      context "empty array" do
        let(:hourly_rates) { [] }
        it { is_expected.to be_empty }
        it { is_expected.to be_a Array }
      end
    end
  end

  xdescribe "performance (Skipped because takes quire some time to run)" do
    include RSpec::Benchmark::Matchers

    before(:all) do
      puts "clearing database"
      clear_all
      puts "importing test data"
      `RAILS_ENV=test bundle exec rails db < #{Rails.root.join(*%w(spec factories hourly_rates_test_dataset_200_comp.sql))}`

      @sample_company_id = Company.limit(50).last.id
      @sample_activity_id = Activity.where(company_id: @sample_company_id).first.id
    end

    it "loads fast for company scope" do
      expect {
        ImplicitHourlyRate.where(company_id: @sample_company_id).all
      }.to perform_under(50).ms.sample(10).times
    end

    it "loads very fast when company and activity given" do
      expect {
        ImplicitHourlyRate.where(company_id: @sample_company_id, activity_id: @sample_activity_id).all
      }.to perform_under(50).ms.sample(10).times
    end
  end
end
