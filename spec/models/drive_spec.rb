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



end
