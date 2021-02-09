# frozen_string_literal: true

require "rails_helper"

RSpec.describe DrivePrice, type: :model do
  let(:company) { create(:company) }
  let(:activity) { create(:activity, company: company) }
  let(:vehicle) { create(:vehicle, company: company) }
  let(:driver) { create(:driver, company: company) }
  let(:customer) { create(:customer, client_of: company) }
  let(:site) { create(:site, customer: customer) }

  describe "price" do
    let(:start_time) { 2.hour.ago }
    let(:end_time) { start_time + 2.hours }

    let(:drive) { create(:drive, driver: driver, customer: customer, site: site, activity: activity, vehicle: vehicle, start: start_time, end: end_time) }


    context "without prices" do
      subject { described_class.new drive }

      its(:price) { is_expected.to eq Money.new("0", "CHF")}
      its(:price_per_hour) { is_expected.to eq Money.new("0", "CHF")}
      it { is_expected.not_to be_flat_rate }
    end

    context "with activity hourly price" do
      before do
        vehicle.vehicle_activity_assignments.create(
           activity_id: activity.id, hourly_rate_attributes: { price: "50", valid_from: Season.current.start_date }
        )
      end

      subject { described_class.new drive }

      its(:price) { is_expected.to eq Money.new("10000", "CHF")}
      its(:price_per_hour) { is_expected.to eq Money.new("5000", "CHF")}
      it { is_expected.not_to be_flat_rate }
    end

    context "with site activity flat rate" do
      before do
        site.site_activity_flat_rates.create(
          activity: activity,
          activity_fee_attributes: { active: true, price: "50", valid_from: Season.current.start_date }
        )
      end

      subject { described_class.new drive }

      its(:price) { is_expected.to eq Money.new("5000", "CHF")}
      its(:price_per_hour) { is_expected.to eq Money.new("5000", "CHF")}
      it { is_expected.to be_flat_rate }
    end

    context "with site activity flat rate and activity hourly rate" do
      before do
        vehicle.vehicle_activity_assignments.create(
          activity_id: activity.id, hourly_rate_attributes: { price: "50", valid_from: Season.current.start_date }
        )
        site.site_activity_flat_rates.create(
          activity: activity,
          activity_fee_attributes: { active: true, price: "50", valid_from: Season.current.start_date }
        )
      end

      subject { described_class.new drive }

      its(:price) { is_expected.to eq Money.new("5000", "CHF")}
      its(:price_per_hour) { is_expected.to eq Money.new("5000", "CHF")}
      it { is_expected.to be_flat_rate }
    end
  end
end