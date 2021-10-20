# frozen_string_literal: true

require "rails_helper"

RSpec.describe Vehicle, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(50) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id, :discarded_at) }

  it { is_expected.to belong_to(:company) }

  describe "discard" do
    subject { create(:vehicle) }
    it { is_expected.not_to be_discarded }

    context "discarded" do
      before { subject.discard }
      it { is_expected.not_to validate_uniqueness_of(:name) }
    end
  end

  describe "name" do
    subject { build(:vehicle) }
    context "regular vehicle" do
      its(:display_name) { is_expected.not_to include(I18n.t('activerecord.attributes.vehicle.discarded_postfix')) }
    end

    context "regular vehicle" do
      before { subject.discarded_at = 1.second.ago }
      its(:display_name) { is_expected.to include(I18n.t('activerecord.attributes.vehicle.discarded_postfix')) }
    end
  end

  describe "squish names" do
    subject { build(:vehicle, name: "  name    \n test   ") }

    it "should squish whitespace" do
      subject.save
      expect(subject.name).to eq("name test")
    end

    it "should not throw error if name is nil" do
      subject.name = nil
      expect { subject.save }.not_to raise_error
    end
  end

  describe "travel_expense_rates" do
    let(:vehicle) { create(:vehicle) }

    describe "all travel_expense_rates" do

      let!(:expense_rate) { create(:pricing_hourly_rate, hourly_ratable: vehicle) }
      let!(:expense_rate_old) { create(:pricing_hourly_rate, hourly_ratable: vehicle, valid_from: 1.year.ago) }

      subject { vehicle.hourly_rates }
      it { is_expected.to include(expense_rate) }
      it { is_expected.to include(expense_rate_old) }
    end

    describe "#travel_expanse_rate" do
      let(:old_price) { Money.new(10) }
      let(:current_price) { Money.new(20) }

      context "without existing rates" do
        subject { vehicle.hourly_rate }
        it { is_expected.not_to be_nil }
      end

      context "with existing rate" do
        let!(:expense_rate) { create(:pricing_hourly_rate, hourly_ratable: vehicle, valid_from: 1.week.ago, price: current_price) }

        subject { vehicle.hourly_rate }
        it { is_expected.to eq expense_rate }

      end

      context "with historic expense rates" do
        let!(:expense_rate) { create(:pricing_hourly_rate, hourly_ratable: vehicle, price: current_price) }
        let!(:expense_rate_old) { create(:pricing_hourly_rate, hourly_ratable: vehicle, valid_from: 1.year.ago, price: old_price) }

        subject { vehicle.hourly_rate }
        it { is_expected.to eq expense_rate }
      end

    end

    describe "#travel_expense_rate=value" do
      let(:new_price) { Money.new(20) }
      let(:valid_from) { 1.month.ago.to_date }

      context "without existing rates" do
        before { vehicle.hourly_rate_attributes = { price: new_price, valid_from: valid_from } }
        subject { vehicle }

        it "creates a new expense_rate" do
          expect { subject.save }.to change(Pricing::HourlyRate, :count).by(1)
        end
      end

      context "with existing expense_rate having different valid_from" do
        let!(:expense_rate_old) { create(:pricing_hourly_rate, hourly_ratable: vehicle, valid_from: valid_from - 1.year) }

        before { vehicle.hourly_rate_attributes = { price: new_price, valid_from: valid_from } }
        subject { vehicle }

        it "creates a new expense_rate" do
          expect { subject.save }.to change(Pricing::HourlyRate, :count).by(1)
        end

        it "sets #travel_expense_rate to the new one" do
          subject.save
          expect(subject.hourly_rate.valid_from).to eq valid_from
        end
      end

      context "with existing expense_rate having same valid_from" do
        let(:old_price) { new_price + Money.new(20) }
        let!(:expense_rate_old) { create(:pricing_hourly_rate, hourly_ratable: vehicle, valid_from: valid_from, price: old_price) }

        before { vehicle.hourly_rate_attributes = { price: new_price, valid_from: valid_from } }
        subject { vehicle }

        it "creates a new expense_rate" do
          expect { subject.save }.not_to change(Pricing::HourlyRate, :count)
        end

        it "updates the existing rate" do
          subject.save
          expect(subject.hourly_rate.price).to eq new_price
        end
      end

      context "with invalid vehicle" do
        before do
          vehicle.name = ""
          vehicle.hourly_rate_attributes = { price: new_price, valid_from: valid_from }
          vehicle.save
        end

        it "is expected to keep assigned hourly rate values" do
          expect(vehicle.hourly_rate.price).to eq new_price
        end

      end
    end
  end

  describe "updated_at when adding driving_routes" do
    subject { create(:vehicle) }
    let(:driving_route) { create(:driving_route) }
    it "touches site" do
      expect {
        subject.update( driving_route_ids:  [driving_route.id])
        subject.reload
      }.to change(subject, :updated_at)
    end
  end
end
