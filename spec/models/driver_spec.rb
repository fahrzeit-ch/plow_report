require 'rails_helper'

RSpec.describe Driver, type: :model do

  let(:valid_attributes) { { name: 'Sample Driver' } }

  describe 'validation' do
    it 'should be valid with valid attributes' do
      expect(Driver.new valid_attributes).to be_valid
    end

    it 'should not be valid without a name' do
      attrs = valid_attributes.except(:name)
      expect(Driver.new(attrs)).not_to be_valid
    end
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

end
