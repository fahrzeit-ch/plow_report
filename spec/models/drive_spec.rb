require 'rails_helper'

RSpec.describe Drive, type: :model do
  let(:driver1) { Driver.create(name: 'Test Driver')}

  subject { Drive.new start: 1.hour.ago, end: DateTime.now, distance_km: 0, driver: driver1 }

  describe 'validation' do

    it 'should be after start' do
      subject.end = 2.hours.ago
      expect(subject).not_to be_valid
    end

  end

  describe '#company' do
    let(:company) { create(:company) }

    before { driver1.update_attribute(:company, company) }

    it 'should return the company of the driver' do
      expect(subject.company).to eq(company)
    end
  end

  describe 'season scope' do
    let(:this_season) { Drive.create(start: DateTime.parse('2018-01-20 12:30'), end: DateTime.parse('2018-01-20 13:50'), driver: driver1 ) }
    let(:last_season) { Drive.create(start: DateTime.parse('2017-01-20 12:30'), end: DateTime.parse('2017-01-20 13:50'), driver: driver1 ) }

    it 'should scope to only the current season' do
      expect(Drive.by_season(Season.current)).to include this_season
      expect(Drive.by_season(Season.current)).not_to include last_season
    end
  end

  describe '#suggested_values' do
    let(:driver) { create(:driver) }
    let(:opts) { {salt_refilled: true, plowed: false, salted: false} }

    before {
      create(:drive, driver: driver, start: '2018-02-01 12:00', end: '2018-02-01 12:30', distance_km: 1, salt_refilled: true, plowed: false, salted: false)
      create(:drive, driver: driver, start: '2018-02-02 12:00', end: '2018-02-02 12:30', distance_km: 2, salt_refilled: true, plowed: true, salted: false)
      create(:drive, driver: driver, start: '2018-02-03 12:00', end: '2018-02-03 12:30', distance_km: 3, salt_refilled: true, plowed: false, salted: true)
      create(:drive, driver: driver, start: '2018-02-04 12:00', end: '2018-02-04 12:30', distance_km: 4, salt_refilled: false, plowed: false, salted: true)
      create(:drive, driver: driver, start: '2018-02-05 12:00', end: '2018-02-05 12:30', distance_km: 5, salt_refilled: false, plowed: true, salted: true)
    }

    subject { described_class.suggested_values(driver, opts)[:distance_km] }

    context 'salt refill only' do

      it 'should return the correct km' do
        expect(subject).to eq 1
      end

    end

    context 'salt refill and plowed' do
      let(:opts) { {salt_refilled: true, plowed: true, salted: false} }

      it 'should return the correct km' do
        expect(subject).to eq 3
      end
    end

    context 'salt refill and salted' do
      let(:opts) { {salt_refilled: true, plowed: false, salted: true} }
      it 'should return the correct km' do
        expect(subject).to eq 3
      end
    end

    context 'salt refill, salted and plowed' do
      let(:opts) { {salt_refilled: true, plowed: true, salted: true} }

      it 'should return the correct km' do
        expect(subject).to eq 3
      end
    end

    context 'plowed or salted only' do
      let(:opts) { {salt_refilled: false, plowed: true, salted: true} }

      it 'should return the correct km' do
        expect(subject).to eq 5
      end
    end

    context 'no opts given' do
      let(:opts) { {} }

      it 'should return the correct km' do
        expect(subject).to eq 0.0
      end
    end
  end

end
