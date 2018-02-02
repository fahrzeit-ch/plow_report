require 'rails_helper'

RSpec.describe User, type: :model do

  let(:valid_attributes) { { name: 'Some Name', email: 'my@valid.mail', password: 'secret', password_confirmation: 'secret' } }

  describe 'validation' do

    it 'should be valid with valid attributes' do
      expect(User.new(valid_attributes)).to be_valid
    end

    it 'should not be valid without name' do
      attrs = valid_attributes.except(:name)
      expect(User.new(attrs)).not_to be_valid
    end

  end

  describe 'drivers' do

    it 'should create a driver when creating a user' do
      expect {
        User.create valid_attributes
      }.to change(Driver, :count).by 1
    end

    it 'should copy name of user to driver' do
      u = User.create valid_attributes
      expect(u.drivers.last.name).to eq u.name
    end

  end


end
