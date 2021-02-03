require 'rails_helper'

RSpec.describe Pricing::HourlyRate, type: :model do

  it { is_expected.to monetize(:price_cents) }

  describe "defaults" do
    subject { described_class.new }
    its(:price) { is_expected.to eq Money.new("0.0") }
    its(:valid_from) { is_expected.to be_between(DateTime.current - 1.second, DateTime.current + 1.second) }
  end

  describe "validity scopes" do
    let!(:hourly_rate_old) { create(:pricing_hourly_rate, valid_from: 1.year.ago) }
    let!(:hourly_rate_new) { create(:pricing_hourly_rate, valid_from: 1.day.ago) }

    describe "#for_date" do
      context "date previous to first valid_from" do
        subject { described_class.for_date(2.years.ago) }
        it { is_expected.to be_nil }
      end

      context "date between current and last valid_from" do
        subject { described_class.for_date(1.month.ago) }
        it { is_expected.to eq(hourly_rate_old) }
      end
    end

    describe "current" do
      subject { described_class.current }
      it { is_expected.to eq(hourly_rate_new) }
    end
  end

end
