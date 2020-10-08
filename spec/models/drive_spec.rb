require 'rails_helper'

RSpec.describe Drive, type: :model do
  let(:driver1) { Driver.create(name: 'Test Driver')}

  subject { Drive.new start: 1.hour.ago, end: Time.current, distance_km: 0, driver: driver1 }

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

  describe 'customer and site' do
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:site) }

    context 'customer without site' do
      let(:customer) { create(:customer) }
      subject { build(:drive, customer: customer, site: nil) }
      it { is_expected.to be_valid }
    end

    context 'site without customer' do
      let(:site) { create(:site) }
      subject { build(:drive, customer: nil, site: site) }
      it { is_expected.to be_valid }
    end

    context 'sites customer different than drives customer' do
      let(:site) { create(:site) }
      let(:customer) { create(:customer) }
      subject { build(:drive, customer: customer, site: site) }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#activity_value_summary' do
    let(:activity1) { create(:activity, value_label: 'Salz', has_value: true) }
    let(:activity2) { create(:activity, value_label: 'Kies', has_value: true) }

    let(:drive1) { create(:drive, activity_execution_attributes: { activity_id: activity1.id, value: 12})}
    let(:drive2) { create(:drive, activity_execution_attributes: { activity_id: activity2.id, value: 2})}
    let(:drive3) { create(:drive, activity_execution_attributes: { activity_id: activity1.id, value: 10})}

    before { drive1; drive2; drive3 }

    subject { described_class.activity_value_summary }

    it 'should include one row for each value label' do
      expect(subject.length).to eq 2
    end

    it 'includes titles of the value labels' do
      expect(subject[1][:title]).to eq 'Salz'
      expect(subject[0][:title]).to eq 'Kies'
    end

    it 'calculates the total of each' do
      expect(subject[1][:total]).to eq 22.0
      expect(subject[0][:total]).to eq 2
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

  describe '#discarded' do
    let(:driver) { create(:driver) }
    let(:tour) { create(:tour, driver: driver, start_time: Time.current)}

    context '#discarded tour' do
      subject { create(:drive, tour: tour, driver: driver) }
      before { tour.discard }

      it { is_expected.not_to be_kept }

      it 'is not in the default scope' do
        expect(Drive.all).not_to include(subject)
      end
    end

    context 'discarded drive in a tour' do
      subject { create(:drive, tour: tour, driver: driver) }
      before { subject.discard }

      it 'is not in default scope' do
        expect(Drive.all).not_to include(subject)
      end
    end

    context 'non discarded drive with a non discarded tour' do
      subject { create(:drive, tour: tour, driver: driver) }
      it 'is in default scope' do
        expect(Drive.all).to include(subject)
      end
    end

    context 'non discarded drive without tour' do
      subject { create(:drive, driver: driver) }

      it 'is in default scope' do
        expect(Drive.all).to include(subject)
      end
    end

  end

  describe 'changed_since scope' do
    let!(:old_drive1) { create(:drive, created_at: 4.days.ago, updated_at: 3.days.ago) }
    let!(:new_drive1) { create(:drive, created_at: 4.days.ago, updated_at: 10.minutes.ago) }
    let!(:discarded_drive) { create(:drive, created_at: 4.days.ago, updated_at: 3.days.ago, discarded_at: 2.minutes.ago) }

    subject { Drive.unscoped.changed_since(11.minutes.ago) }
    it { is_expected.to include(new_drive1) }
    it { is_expected.to include(discarded_drive) }
    it { is_expected.not_to include(old_drive1) }
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

  describe 'activity_executions' do
    it { is_expected.to have_one(:activity_execution).dependent(:destroy).autosave(true) }

    describe 'activity name' do
      let(:activity_execution) { create(:activity_execution) }
      let(:activity_name) { activity_execution.activity.name }

      subject { create(:drive, activity_execution: activity_execution) }

      it 'is expected to return the activity name in tasks' do
        expect(subject.tasks).to eq(activity_name)
      end

    end
  end

  describe '#suggested_values' do
    let(:plowing_activity) { create(:activity_execution) }
    let(:salting_activity) { create(:activity_execution_with_value, value: 3) }
    let(:salting_activity2) { create(:activity_execution_with_value, value: 4) }

    let(:driver) { create(:driver) }
    let(:opts) { { activity_id: plowing_activity.activity.id } }

    before {
      create(:drive, driver: driver, start: '2018-02-01 12:00', end: '2018-02-01 12:30', distance_km: 1, activity_execution: salting_activity)
      create(:drive, driver: driver, start: '2018-02-02 12:00', end: '2018-02-02 12:30', distance_km: 2, activity_execution: salting_activity2)
      create(:drive, driver: driver, start: '2018-02-03 12:00', end: '2018-02-03 12:30', distance_km: 3, activity_execution: plowing_activity)
      create(:drive, driver: driver, start: '2018-02-04 12:00', end: '2018-02-04 12:30', distance_km: 4, activity_execution: plowing_activity)
    }

    subject { described_class.suggested_values(driver, opts) }
    it { is_expected.to have_key(:distance_km) }
    it { is_expected.to have_key(:activity_value) }

    describe 'distance' do
      subject { described_class.suggested_values(driver, opts)[:distance_km] }

      context 'latest plow' do
        let(:opts) { { activity_id: plowing_activity.activity.id } }
        it { is_expected.to eq 4.0 }
      end

      context 'latest salting' do
        let(:opts) { { activity_id: salting_activity.activity.id } }
        it { is_expected.to eq 1.0 }
      end
    end

    describe 'activity_value' do
      subject { described_class.suggested_values(driver, opts)[:activity_value] }

      context 'latest salting' do
        let(:opts) { { activity_id: salting_activity2.activity.id } }
        it { is_expected.to eq 4.0 }
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

  describe 'hourly_rates' do
    # We need to disable transactional specs because implicit hourly rates is based on a db view
    # which will not be populated until the transaction is committed.
    self.use_transactional_tests = false

    def clear_all
      ActiveRecord::Base.connection.execute('delete from hourly_rates')
      ActiveRecord::Base.connection.execute('delete from customers')
      ActiveRecord::Base.connection.execute('delete from activities')
      ActiveRecord::Base.connection.execute('delete from companies')
    end
    before(:all) { clear_all }
    after(:all) { clear_all }

    let(:company) { create(:company) }
    let(:driver) { build(:driver, company_id: company.id ) }
    let(:drive) { build(:drive, driver: driver) }

    before { hourly_rate }

    subject { drive.hourly_rate }

    context 'without activity or customer' do
      let(:hourly_rate) { create(:hourly_rate, company_id: company.id, activity: nil, customer: nil ) }
      it { is_expected.to be_a Money }
      it { is_expected.to eq hourly_rate.price }
    end



  end

end
