
require "rails_helper"

RSpec.describe Report::DriveRowBuilder, type: :model do
  let(:company) { create(:company) }
  let(:activity) { create(:activity, company: company) }
  let(:vehicle) { create(:vehicle, company: company) }
  let(:driver) { create(:driver, company: company) }
  let(:customer) { create(:customer, client_of: company) }
  let(:site) { create(:site, customer: customer) }

  subject { described_class.new nil, nil }

  describe "price columns" do
    let(:start_time) { 2.hour.ago }
    let(:end_time) { start_time + 2.hours }

    let(:drive) { create(:drive, driver: driver, customer: customer, site: site, activity: activity, vehicle: vehicle, start: start_time, end: end_time) }


    context "without prices" do
      it { expect(subject.get_price(drive)).to eq 0.0 }
      it { expect(subject.get_travel_expense(drive)).to eq 0.0 }
      it { expect(subject.get_hourly_rate(drive)).to eq 0.0 }
      it { expect(subject.get_travel_expense_rate(drive)).to eq 0.0 }
    end

    context "with activity hourly price" do
      before do
        vehicle.vehicle_activity_assignments.create(
          activity_id: activity.id, hourly_rate_attributes: { price: "50", valid_from: Season.current.start_date }
        )
      end

      it { expect(subject.get_price(drive)).to eq 100.0 }
      it { expect(subject.get_travel_expense(drive)).to eq 0.0 }
      it { expect(subject.get_hourly_rate(drive)).to eq 50.0 }
      it { expect(subject.get_travel_expense_rate(drive)).to eq 0.0 }
    end

    context "with site activity flat rate" do
      before do
        site.site_activity_flat_rates.create(
          activity: activity,
          activity_fee_attributes: { active: true, price: "50", valid_from: Season.current.start_date }
        )
      end

      it { expect(subject.get_price(drive)).to eq 50.0 }
      it { expect(subject.get_travel_expense(drive)).to eq 0.0 }
      it { expect(subject.get_hourly_rate(drive)).to eq "Pauschal" }
      it { expect(subject.get_travel_expense_rate(drive)).to eq 0.0 }
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

      it { expect(subject.get_price(drive)).to eq 50.0 }
      it { expect(subject.get_travel_expense(drive)).to eq 0.0 }
      it { expect(subject.get_hourly_rate(drive)).to eq "Pauschal" }
      it { expect(subject.get_travel_expense_rate(drive)).to eq 0.0 }
    end

    context "with deleted vehicle" do
      before do
        vehicle.vehicle_activity_assignments.create(
          activity_id: activity.id, hourly_rate_attributes: { price: "50", valid_from: Season.current.start_date }
        )
        vehicle.discard
      end

      it { expect(subject.get_price(drive)).to eq 100.0 }
      it { expect(subject.get_travel_expense(drive)).to eq 0.0 }
      it { expect(subject.get_hourly_rate(drive)).to eq 50.0 }
      it { expect(subject.get_travel_expense_rate(drive)).to eq 0.0 }
    end

    context "with inactive site activity flat rate and activity hourly rate" do
      before do
        vehicle.vehicle_activity_assignments.create(
          activity_id: activity.id, hourly_rate_attributes: { price: "50", valid_from: Season.current.start_date }
        )
        site.site_activity_flat_rates.create(
          activity: activity,
          activity_fee_attributes: { active: false, price: "50", valid_from: Season.current.start_date }
        )
      end

      it { expect(subject.get_price(drive)).to eq 100.0 }
      it { expect(subject.get_travel_expense(drive)).to eq 0.0 }
      it { expect(subject.get_hourly_rate(drive)).to eq 50.0 }
      it { expect(subject.get_travel_expense_rate(drive)).to eq 0.0 }
    end

    context "with historic activity hourly rate" do
      let(:start_time) { Season.current.start_date - 2.hours }
      let(:end_time) { start_time + 2.hours }
      before do
        vehicle.vehicle_activity_assignments.create(
          activity_id: activity.id, hourly_rate_attributes: { price: "50", valid_from: Season.current.start_date }
        )
        vehicle.vehicle_activity_assignments.first.update(
          hourly_rate_attributes: { price: "80", valid_from: Season.last(2)[0].start_date }
        )
      end

      it { expect(subject.get_price(drive)).to eq 160.0 }
      it { expect(subject.get_travel_expense(drive)).to eq 0.0 }
      it { expect(subject.get_hourly_rate(drive)).to eq 80.0 }
      it { expect(subject.get_travel_expense_rate(drive)).to eq 0.0 }
    end

    context "with historic activity flat rate" do
      let(:start_time) { Season.current.start_date - 2.hours }
      let(:end_time) { start_time + 2.hours }
      before do
        vehicle.vehicle_activity_assignments.create(
          activity_id: activity.id, hourly_rate_attributes: { price: "50", valid_from: Season.current.start_date }
        )
        site.site_activity_flat_rates.create(
          activity: activity,
          activity_fee_attributes: { active: true, price: "50", valid_from: Season.current.start_date }
        )
        site.site_activity_flat_rates.first.update(
          activity_fee_attributes: { active: true, price: "80", valid_from: Season.last(2)[0].start_date }
        )
      end

      it { expect(subject.get_price(drive)).to eq 80.0 }
      it { expect(subject.get_travel_expense(drive)).to eq 0.0 }
      it { expect(subject.get_hourly_rate(drive)).to eq "Pauschal" }
      it { expect(subject.get_travel_expense_rate(drive)).to eq 0.0 }

    end
  end
end
