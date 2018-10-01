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
    let(:this_season) { Drive.create!(start: DateTime.parse('2018-01-20 12:30'), end: DateTime.parse('2018-01-20 13:50'), driver: driver1 ) }
    let(:last_season) { Drive.create!(start: DateTime.parse('2017-01-20 12:30'), end: DateTime.parse('2017-01-20 13:50'), driver: driver1 ) }

    it 'should scope to only the current season' do
      season = Season.from_date(Date.parse('2018-01-20'))
      expect(Drive.by_season(season)).to include this_season
      expect(Drive.by_season(season)).not_to include last_season
    end
  end

  describe '#surcharge_rate_type' do
    let(:start_time) { DateTime.parse('2018-08-21 12:30') }
    let(:end_time) { DateTime.parse('2018-08-21 13:30') }
    let(:drive) { create(:drive, start: start_time, end: end_time, driver: driver1) }

    subject { drive.surcharge_rate_type }

    context 'no rules apply' do
      it 'should return 0' do
        expect(subject).to eq(0)
      end
    end

    context 'weekend' do
      let(:start_time) { DateTime.parse('2018-08-19 23:59+02:00') }
      let(:end_time) { DateTime.parse('2018-08-20 00:30+02:00') }

      it 'should return default_rate' do
        expect(subject).to eq(1)
      end
    end
  end

  # describe 'activities' do
  #   it { is_expected.to respond_to(:activities) }
  #   it { expect(subject.activities).to be_a Hash }
  #
  #   it 'should be possible to persist any kind of activity' do
  #     expect { subject.update(activities: { plowed: true }) }.not_to raise_error
  #   end
  # end

  describe 'salt_amount_tonns' do

    context 'salt_refilled is false and amount has value > 0' do

      before {
        subject.salt_amount_tonns = 20
        subject.salt_refilled = false
      }

      it 'should be valid' do
        expect(subject).to be_valid
      end

      it 'should set salt amount to 0 when salt_refilled set to false' do
        subject.validate
        expect(subject.salt_amount_tonns).to eq 0
      end
    end

    context 'sqalt_refilled is true and salt_amount is 0' do
      before {
        subject.salt_refilled = true
        subject.salt_amount_tonns = 0
      }

      it 'should not be valid' do
        expect(subject).not_to be_valid
      end

      it 'should have error on salt_amount_tonns' do
        subject.validate
        expect(subject.errors).to have_key(:salt_amount_tonns)
      end
    end

  end

  describe '#suggested_values' do
    let(:driver) { create(:driver) }
    let(:opts) { {salt_refilled: true, plowed: false, salted: false} }

    before {
      create(:drive, driver: driver, start: '2018-02-01 12:00', end: '2018-02-01 12:30', distance_km: 1, salt_refilled: true, salt_amount_tonns: 1, plowed: false, salted: false)
      create(:drive, driver: driver, start: '2018-02-02 12:00', end: '2018-02-02 12:30', distance_km: 2, salt_refilled: true, salt_amount_tonns: 2, plowed: true, salted: false)
      create(:drive, driver: driver, start: '2018-02-03 12:00', end: '2018-02-03 12:30', distance_km: 3, salt_refilled: true, salt_amount_tonns: 3, plowed: false, salted: true)
      create(:drive, driver: driver, start: '2018-02-04 12:00', end: '2018-02-04 12:30', distance_km: 4, salt_refilled: false, plowed: false, salted: true)
      create(:drive, driver: driver, start: '2018-02-05 12:00', end: '2018-02-05 12:30', distance_km: 5, salt_refilled: false, plowed: true, salted: true)
    }

    describe 'distance' do
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

    describe 'salt amount' do
      variants = [ {salt_refilled: true, plowed: false, salted: false},
                   {salt_refilled: true, plowed: true, salted: false},
                   {salt_refilled: true, plowed: true, salted: true}
      ]
      variants.each do |options|
        it 'is allways last value for salt amount' do
          amount = described_class.suggested_values(driver, options)[:salt_amount_tonns]
          expect(amount).to eq 3
        end
      end

      it 'returns zero for drives without salt refill' do
        options = {salt_refilled: false, plowed: false, salted: false}
        amount = described_class.suggested_values(driver, options)[:salt_amount_tonns]
        expect(amount).to eq 0
      end
    end
  end

  describe 'user action' do

    it 'should have relation to user action' do
      expect(subject.user_actions).to be_a ActiveRecord::Relation
    end

    context 'actions not loaded' do
      it do
        expect(subject.seen?).to be_falsey
      end
    end

    context 'actions loaded and record seen by user' do
      subject { described_class.with_viewstate(visitor).first }

      let(:drive) { create(:drive) }
      let(:user) { create(:user) }
      let(:visitor) { user }

      before do
        UserAction.track_list(user, [drive])
      end

      it 'seen? should be true' do
        expect(subject).to be_seen
      end

      context 'different user' do
        let(:visitor) { create(:user) }

        it 'should have set seen? to false' do
          expect(subject).not_to be_seen
        end
      end
    end

  end
end
