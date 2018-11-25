require 'rails_helper'

RSpec.describe Driver, type: :model do

  let(:valid_attributes) { { name: 'Sample Driver' } }

  describe 'validation' do
    it 'should be valid with valid attributes' do
      expect(Driver.new valid_attributes).to be_valid
    end

    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'driver_logins' do
    let(:user1) { User.create( name: 'Hans 1', email: '1@2.com', password: 'secret', password_confirmation: 'secret') }
    let(:user2) { User.create( name: 'Hans 2', email: '1@2.com', password: 'secret', password_confirmation: 'secret') }

    subject { Driver.create(name: 'Driver 1') }

    it 'should create driver_login when assigning user' do
      subject.user = user1
      user1.reload
      expect(user1.driver_logins.count).to eq 2
    end

    it 'destroys driver login when delete driver' do
      subject.user = user1
      expect{subject.destroy!}.to change(DriverLogin, :count).by -1
    end

    it 'does not delete user when delete driver' do
      subject.user = user1
      expect{subject.destroy!}.not_to change(User, :count)
    end

  end

  describe '#destroy' do
    subject { described_class.create(valid_attributes) }

    before { create_list(:drive, 2, driver: subject) }

    it 'should delete all drives' do
      expect{
        subject.destroy!
      }.to change(Drive, :count).by -2
    end

  end

  describe '#start_recording' do

    it 'should create a recording record' do
      expect {
        subject.start_recording
      }.to change(Recording, :count).by 1
    end

    it 'should raise error when trin to start recording twice' do
      subject.start_recording
      expect {
        subject.start_recording
      }.to raise_error
    end

    it 'should save current time as start for recording' do
      subject.start_recording
      expect(subject.recording.start_time).to be_between(1.seconds.ago, 1.second.from_now)
    end

  end

  describe '#finish recording' do
    before { subject.start_recording }

    it 'should return start time of the recording' do
      expect(subject.finish_recording).to be_a Time
    end

    it 'should not be recording anymore' do
      subject.finish_recording
      expect(subject).not_to be_recording
    end
  end

  describe 'change company' do
    let(:driver) { create(:driver, company: nil) }

    context 'with running recording' do
      subject { driver }

      before { subject.start_recording }
      it 'should not be valid' do
        subject.company = create(:company)
        expect(subject).not_to be_valid
      end
    end

    context 'with drives with an activity' do
      let(:activity1) { create(:activity) }
      let(:drive) { create(:drive, activity: activity1, driver: driver) }

      let(:company) { create(:company) }

      before do
        drive
      end

      subject { driver.update(company: company) }

      it 'copies activity to company' do
        expect { subject }.to change(company.activities, :count).by 1
      end

    end
  end

end
