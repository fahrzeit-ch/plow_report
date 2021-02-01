require 'rails_helper'

RSpec.describe ToursReport, type: :model do
  it { is_expected.to respond_to(:date_range) }

  describe "date_range" do
    describe "date range write" do
      subject { described_class.new(date_range: "01.01.2021 00:00 - 31.01.2021 23:59") }
      its(:start_date) { is_expected.to eq(DateTime.parse("2021-01-01T00:00")) }
      its(:end_date) { is_expected.to eq(DateTime.parse("2021-01-31T23:59")) }
    end

    describe "date range read" do
      subject { described_class.new(start_date: "2021-01-01T00:00", end_date: "2021-01-31T23:59") }
      its(:date_range) { is_expected.to eq("01.01.2021 00:00 - 31.01.2021 23:59") }
    end

    context "invalid date range" do
      subject { described_class.new(date_range: "01.33.2021 00:00 - 31.01.2021 23:59") }
      it { is_expected.not_to be_valid }
    end
  end

end
