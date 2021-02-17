# frozen_string_literal: true

require "rails_helper"

RSpec.describe Tour, type: :model do
  describe "validation" do
    subject { described_class.new(start_time: 1.hour.ago, end_time: 1.minute.ago) }

    it { is_expected.to allow_value(subject.start_time + 1.minute).for(:end_time) }
    it { is_expected.to_not allow_value(subject.start_time - 1.minute).for(:end_time) }

    describe "drive_time_not_more_than_tour_time" do
      let(:start_time) { 3.hours.ago }
      let(:end_time) { 1.hour.ago }
      let(:tour) { create(:tour, start_time: start_time, end_time: end_time) }

      let(:drive1) { create(:drive, start: start_time, end: 2.hour.ago) }
      let(:drive2) { create(:drive, start: 2.hours.ago, end: end_time) }

      before do
        tour.drives = [drive1, drive2]
        tour.full_validation = true
        tour.valid?
      end

      subject { tour }
      it { is_expected.to be_valid }
    end
  end

  it { is_expected.to belong_to(:vehicle).optional }

  describe "#drives" do
    let(:tour) { build(:tour) }

    let(:drive1) { build(:drive, start: 1.hour.ago, end: 59.minutes.ago) }
    let(:drive2) { build(:drive, start: 2.hours.ago, end: 1.hour.ago) }
    let(:drive3) { build(:drive, start: 3.hours.ago, end: 2.hour.ago) }

    before { tour.drives = [drive2, drive1, drive3] }

    subject { tour }

    context "persisted" do
      let(:tour) { create(:tour, driver: create(:driver), start_time: 4.hours.ago) }

      before do
        drive1.save!
        drive2.save!
        drive3.save!

        tour.save!
        tour.reload
      end

      its(:first_drive) { is_expected.to eq drive3 }
      its(:last_drive) { is_expected.to eq drive1 }
    end
  end

  describe "discard tour" do
    let(:driver) { create(:driver) }
    subject { create(:tour, driver: driver, start_time: 4.hours.ago, drives: build_list(:drive, 2, driver: driver)) }

    before {
      subject.discard
    }
    it { is_expected.to be_discarded }
  end

  describe "durations" do
    let(:tour) { create(:tour) }
    let(:start) { 1.hour.ago }

    context "with drives" do
      let(:end_time) { start + 10.minutes }
      let!(:drives) { create_list(:drive, 2, tour: tour, start: start, end: end_time) }

      subject { tour }
      its(:drives_duration) { is_expected.to eq 20.minutes }
    end

    context "without drives" do
      subject { tour }
      its(:drives_duration) { is_expected.to eq 0.minutes }
    end

    context "discarded drives" do
      let(:end_time) { start + 10.minutes }
      let!(:drives) { create_list(:drive, 2, tour: tour, start: start, end: end_time, discarded_at: 1.minute.ago) }

      subject { tour }
      its(:drives_duration) { is_expected.to eq 0.minutes }
    end
  end

  describe "changed_since scope" do
    let!(:old_tour1) { create(:tour, created_at: 4.days.ago, updated_at: 3.days.ago) }
    let!(:new_tour1) { create(:tour, created_at: 4.days.ago, updated_at: 10.minutes.ago) }
    let!(:discarded_tour) { create(:tour, created_at: 4.days.ago, updated_at: 3.days.ago, discarded_at: 2.minutes.ago) }

    subject { Tour.unscoped.changed_since(11.minutes.ago) }
    it { is_expected.to include(new_tour1) }
    it { is_expected.to include(discarded_tour) }
    it { is_expected.not_to include(old_tour1) }
  end

  describe "update from drives" do
    let(:tour) { create(:tour, start_time: 2.minutes.ago, end_time: 1.minute.ago) }
    let!(:drive) { create(:drive, tour: tour, start: 3.minutes.ago, end: 2.seconds.ago) }

    subject { tour.reload }

    context "when adding drive" do
      its(:start_time) { is_expected.to be_within(0.1.seconds).of(drive.start) }
      its(:end_time) { is_expected.to be_within(0.1.seconds).of(drive.end) }
    end

    context "removing drive" do
      it "should not update start and end times" do
        expect { drive.discard }.not_to change(subject, :start_time)
      end
    end

    context "when changing time on drive" do
      it "should update end_time" do
        expect { drive.update_attribute(:end, 1.second.ago) }.to change(tour, :end_time)
      end
    end
  end

  describe "update drives on changes" do
    let(:company) { create(:company) }
    subject { create(:tour, driver: create(:driver, company: company)) }
    let(:drive) { create(:drive, tour: subject) }

    it "changes the vehicle of the drive when updating tour vehicle" do
      new_vehicle = create(:vehicle, company: company)
      expect {
        subject.update_attribute(:vehicle, new_vehicle)
        drive.reload
      }.to change(drive, :vehicle).to new_vehicle
    end
  end

  describe "vehicle assignment" do
    let(:driver) { create(:driver, company: create(:company)) }
    let(:vehicle) { create(:vehicle, company: create(:company)) }

    subject { described_class.new(vehicle: vehicle, driver: driver, start_time: 4.hours.ago) }

    it "is expected not to have errors when vehicle is not in same company as driver" do
      subject.valid?
      expect(subject.errors[:vehicle].count).to be > 0
    end
  end

  describe "active tour" do
    context "end_time set" do
      subject { create(:tour, end_time: 1.minute.from_now) }
      it { is_expected.not_to be_active }
    end

    context "end_time not set" do
      subject { create(:tour, end_time: nil) }
      it { is_expected.to be_active }

      its(:duration_seconds) { is_expected.to be 0 }
    end
  end

  describe "#first_of_site" do
    let(:start_time) { 3.hours.ago }
    let(:tour) { create(:tour, start_time: start_time, end_time: start_time + 3.hours) }
    let(:site1) { create(:site) }
    let(:site2) { create(:site) }
    let!(:drive_1) { create(:drive, tour: tour, start: start_time, end: start_time + 20.minutes, vehicle: tour.vehicle, site: site1) }
    let!(:drive_2) { create(:drive, tour: tour, start: start_time + 30.minutes, end: start_time + 1.hour, vehicle: tour.vehicle, site: site1) }
    let!(:drive_3) { create(:drive, tour: tour, start: start_time + 1.hour, end: start_time + 1.5.hours, vehicle: tour.vehicle, site: site2) }

    it "returns drive 1 for site 1" do
      expect(tour.first_of_site(site1.id)).to eq drive_1
    end

    it "returns drive 3 for site 2" do
      expect(tour.first_of_site(site2.id)).to eq drive_3
    end

  end


end
