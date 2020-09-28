require 'rails_helper'

RSpec.describe Tour, type: :model do


  describe 'validation' do
    subject { described_class.new(start_time: 1.hour.ago, end_time: 1.minute.ago)}

    it { is_expected.to allow_value(subject.start_time + 1.minute).for(:end_time) }
    it { is_expected.to_not allow_value(subject.start_time - 1.minute).for(:end_time) }
  end

  describe '#sorted_drives' do
    let(:tour) { build(:tour) }

    let(:drive1) { build(:drive, start: 1.hour.ago, end: 59.minutes.ago) }
    let(:drive2) { build(:drive, start: 2.hours.ago, end: 1.hour.ago) }
    let(:drive3) { build(:drive, start: 3.hours.ago, end: 2.hour.ago) }

    before { tour.drives = [drive1, drive2, drive3] }

    subject { tour }

    context 'non persisted' do
      its(:first_drive) { is_expected.to eq drive3 }
      its(:last_drive) { is_expected.to eq drive1 }
    end

    context 'persisted' do
      let(:tour) { create(:tour, driver: create(:driver), start_time: 4.hours.ago) }

      before do
        drive1.save!
        drive2.save!
        drive3.save!

        tour.save!
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


end
