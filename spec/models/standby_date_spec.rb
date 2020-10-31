# frozen_string_literal: true

require "rails_helper"

RSpec.describe StandbyDate, type: :model do
  let(:driver) { create(:driver) }
  subject { described_class.new driver: driver, day: Date.today }

  describe "validation" do
    context "same date" do
      it "should not be valid for same driver" do
        StandbyDate.create(driver: driver, day: Date.today)
        expect(subject).not_to be_valid
      end

      it "should be valid for different driver" do
        StandbyDate.create(driver: create(:driver), day: Date.today)
        expect(subject).to be_valid
      end
    end
  end

  describe "last_in_season" do
    let(:season) { Season.last(2)[0] }
    let(:first_in_season) { create(:standby_date, day: season.start_date) }
    let(:last_in_season) { create(:standby_date, day: season.start_date + 1.day) }
    let(:other_season) { create(:standby_date, day: season.end_date + 1.day) }

    before { first_in_season; last_in_season; other_season }

    it "should return last standby date of given season" do
      expect(described_class.last_in_season(season)).to eq(last_in_season)
    end
  end

  describe "scopes" do
    describe "calendar view" do
      let(:date) { Date.parse("2018-02-14") }
      let(:not_in_scope) { create(:standby_date, day: "2018-01-28") }
      let(:in_scope1) { create(:standby_date, day: "2018-01-29") }
      let(:in_scope2) { create(:standby_date, day: "2018-03-04") }

      before { not_in_scope; in_scope1; in_scope2 }

      subject { described_class.by_calendar_month(date) }

      it { is_expected.to include(in_scope1, in_scope2) }
      it { is_expected.not_to include(not_in_scope) }
    end

    describe "by_season" do
      let(:season) { Season.current }
      let(:not_in_scope) { create(:standby_date, day: season.start_date - 1.day) }
      let(:in_scope1) { create(:standby_date, day: season.start_date) }
      let(:in_scope2) { create(:standby_date, day: season.end_date) }

      before { not_in_scope; in_scope1; in_scope2 }

      subject { described_class.by_season(season) }

      it { is_expected.to include(in_scope1, in_scope2) }
      it { is_expected.not_to include(not_in_scope) }
    end
  end
end

RSpec.describe StandbyDate::DateRange, type: :model do
  let(:driver) { create(:driver) }

  describe "date conversion" do
    it "should convert string to date" do
      range = StandbyDate::DateRange.new(start_date: "2018-12-12", end_date: "2018-12-13")
      expect(range.start_date).to be_a(Date)
      expect(range.end_date).to be_a(Date)
    end

    it "should work for dates as well" do
      range = StandbyDate::DateRange.new(start_date: Date.today, end_date: Date.tomorrow)
      expect(range.start_date).to be_a(Date)
      expect(range.end_date).to be_a(Date)
    end
  end

  describe "#save" do
    it "should silently ignore already created dates" do
      StandbyDate.create(driver: driver, day: Date.today)
      expect {
        StandbyDate::DateRange.new(start_date: Date.yesterday, end_date: Date.tomorrow, driver_id: driver.id).save
      }.to change(StandbyDate, :count).by 2
    end

    describe "validation" do
      it "should not be valid with end_date < start_date" do
        expect(StandbyDate::DateRange.new(start_date: Date.tomorrow, end_date: Date.yesterday, driver_id: driver.id)).not_to be_valid
      end
    end
  end
end
