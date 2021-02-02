require 'rails_helper'

RSpec.describe ToursReport, type: :model do
  it { is_expected.to belong_to(:customer).optional }
  it { is_expected.to respond_to(:date_range) }

  describe "scope validation" do
    context "without drives" do
      subject { described_class.new(date_range: "01.01.2021 00:00 - 31.01.2021 23:59", company: create(:company)) }
      it "is expected to have error in base" do
        subject.valid?
        expect(subject.errors[:base]).not_to be_empty
      end
    end
  end

  describe "date_range" do
    before { Time.zone = Time.zone = "Bern" } # We need to explicitly set this so it matches the DateTime.parse below
    describe "date range write" do
      subject { described_class.new(date_range: "01.01.2021 00:00 - 31.01.2021 23:59") }
      its(:start_date) { is_expected.to eq(DateTime.parse("2021-01-01T00:00 +01:00")) }
      its(:end_date) { is_expected.to eq(DateTime.parse("2021-01-31T23:59 +01:00")) }
    end

    describe "date range read" do
      subject { described_class.new(start_date: "2021-01-01T00:00", end_date: "2021-01-31T23:59") }
      its(:date_range) { is_expected.to eq("01.01.2021 00:00 - 31.01.2021 23:59") }
    end

    context "invalid date range" do
      subject { described_class.new(date_range: "01.33.2021 00:00 - 31.01.2021 23:59") }
      it { is_expected.not_to be_valid }
      it "is expected to have error on date_range" do
        subject.valid?
        expect(subject.errors[:date_range]).not_to be_nil
      end
    end
  end

  describe "drives" do
    let(:company) { create(:company) }


    context "without setting customer filter" do
      let(:customer) { create(:customer, client_of: company) }
      let(:driver) { create(:driver, company: company) }
      let!(:drives_included) { create_list(:drive, 3, start: 1.day.ago, end: 1.day.ago + 1.hour, driver: driver, customer: customer) }
      let!(:drives_not_included) { create_list(:drive, 3, start: 2.day.ago, end: 2.day.ago + 1.hour, driver: driver, customer: customer) }
      let!(:report) { create(:tours_report, company: company, start_date: 1.day.ago.beginning_of_day, end_date: DateTime.current.end_of_day) }

      subject { report.drives }

      it { is_expected.to include(*drives_included) }
      it { is_expected.not_to include(*drives_not_included) }
    end

    context "without setting customer filter" do
      let(:customer) { create(:customer, client_of: company) }
      let(:other_customer) { create(:customer, client_of: company) }
      let(:driver) { create(:driver, company: company) }
      let!(:drives_included) { create_list(:drive, 3, start: 1.day.ago, end: 1.day.ago + 1.hour, driver: driver, customer: customer) }
      let!(:drives_not_included) { create_list(:drive, 3, start: 1.day.ago, end: 1.day.ago + 1.hour, driver: driver, customer: other_customer) }
      let!(:report) { create(:tours_report, company: company, start_date: 1.day.ago.beginning_of_day, end_date: DateTime.current.end_of_day, customer: customer) }

      subject { report.drives }

      it { is_expected.to include(*drives_included) }
      it { is_expected.not_to include(*drives_not_included) }
    end
  end

end
