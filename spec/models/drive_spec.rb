require 'rails_helper'

RSpec.describe Drive, type: :model do

  subject { Drive.new start: 1.hour.ago, end: DateTime.now, distance_km: 0 }

  describe 'validation' do

    it 'end should be after start' do
      subject.end = 2.hours.ago
      expect(subject).not_to be_valid
    end

  end

  describe 'season scope' do
    let(:this_season) { Drive.create(start: DateTime.parse('2018-01-20 12:30'), end: DateTime.parse('2018-01-20 13:50') ) }
    let(:last_season) { Drive.create(start: DateTime.parse('2017-01-20 12:30'), end: DateTime.parse('2017-01-20 13:50') ) }

    it 'should scope to only the current season' do
      expect(Drive.by_season(Season.current)).to include this_season
      expect(Drive.by_season(Season.current)).not_to include last_season
    end
  end
end
