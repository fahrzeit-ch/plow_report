require 'rails_helper'

RSpec.describe StandbyDate, type: :model do

  let(:driver) { create(:driver) }
  subject { described_class.new driver: driver, day: Date.today }

  describe 'validation' do

    context 'same date' do
      it 'should not be valid for same driver' do
        StandbyDate.create(driver: driver, day: Date.today)
        expect(subject).not_to be_valid
      end

      it 'should be valid for different driver' do
        StandbyDate.create(driver: create(:driver), day: Date.today )
        expect(subject).to be_valid
      end
    end

  end
end

RSpec.describe StandbyDate::DateRange, type: :model do
  let(:driver) { create(:driver) }

  describe 'date conversion' do
    it 'should convert string to date' do
      range = StandbyDate::DateRange.new(start_date: '2018-12-12', end_date: '2018-12-13')
      expect(range.start_date).to be_a(Date)
      expect(range.end_date).to be_a(Date)
    end

    it 'should work for dates as well' do
      range = StandbyDate::DateRange.new(start_date: Date.today, end_date: Date.tomorrow)
      expect(range.start_date).to be_a(Date)
      expect(range.end_date).to be_a(Date)
    end
  end

  describe '#save' do
    it 'should silently ignore already created dates' do
      StandbyDate.create(driver: driver, day: Date.today)
      expect {
        StandbyDate::DateRange.new(start_date: Date.yesterday, end_date: Date.tomorrow, driver_id: driver.id).save
      }.to change(StandbyDate, :count).by 2
    end

    describe 'validation' do
      it 'should not be valid with end_date < start_date' do
        expect(StandbyDate::DateRange.new(start_date: Date.tomorrow, end_date: Date.yesterday, driver_id: driver.id)).not_to be_valid
      end
    end

  end
end