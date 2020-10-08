require 'rails_helper'

RSpec.describe Tour, type: :model do


  describe 'validation' do
    subject { described_class.new(start_time: 1.hour.ago, end_time: 1.minute.ago)}

    it { is_expected.to allow_value(subject.start_time + 1.minute).for(:end_time) }
    it { is_expected.to_not allow_value(subject.start_time - 1.minute).for(:end_time) }
  end

  describe '#drives' do
    let(:tour) { build(:tour) }

    let(:drive1) { build(:drive, start: 1.hour.ago, end: 59.minutes.ago) }
    let(:drive2) { build(:drive, start: 2.hours.ago, end: 1.hour.ago) }
    let(:drive3) { build(:drive, start: 3.hours.ago, end: 2.hour.ago) }

    before { tour.drives = [drive2, drive1, drive3] }

    subject { tour }

    context 'persisted' do
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

  describe 'discard tour' do
    let(:driver) { create(:driver) }
    subject { create(:tour, driver: driver, start_time: 4.hours.ago, drives: build_list(:drive, 2, driver: driver)) }

    before {
      subject.discard
    }
    it { is_expected.to be_discarded }
  end

  describe 'durations' do
    let(:tour) { create(:tour) }
    let(:start) { 1.hour.ago }

    context 'with drives' do
      let(:end_time) { start + 10.minutes }
      let!(:drives) { create_list(:drive, 2, tour: tour, start: start, end: end_time ) }

      subject { tour }
      its(:drives_duration) { is_expected.to eq 20.minutes }
    end

    context 'without drives' do
      subject { tour }
      its(:drives_duration) { is_expected.to eq 0.minutes }
    end
  end


end
