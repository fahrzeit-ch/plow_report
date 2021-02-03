require "rails_helper"

RSpec.describe Pricing::FlatRate, type: :model do
  describe "can be associated to customer site" do
    it { is_expected.to belong_to(:flat_ratable) }
  end

  describe "validation" do
    it { is_expected.to validate_inclusion_of(:rate_type).in_array(Pricing::FlatRate::TYPES) }
  end

  it { is_expected.to monetize(:price_cents) }

  describe "defaults" do
    subject { described_class.new }
    its(:price) { is_expected.to eq Money.new("0.0") }
    its(:valid_from) { is_expected.to eq Date.current }
    its(:rate_type) { is_expected.to eq(Pricing::FlatRate::CUSTOM_FEE) }
  end

  describe "validity scopes" do
    let!(:flat_rate_old) { create(:pricing_flat_rate, valid_from: 1.year.ago) }
    let!(:flat_rate_new) { create(:pricing_flat_rate, valid_from: 1.day.ago) }

    describe "#for_date" do
      context "date previous to first valid_from" do
        subject { described_class.for_date(2.years.ago) }
        it { is_expected.to be_nil }
      end

      context "date between current and last valid_from" do
        subject { described_class.for_date(1.month.ago) }
        it { is_expected.to eq(flat_rate_old) }
      end
    end

    describe "current" do
      subject { described_class.current }
      it { is_expected.to eq(flat_rate_new) }
    end
  end
end
