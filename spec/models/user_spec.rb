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

    it 'should skip create_driver when option set' do
      expect {
        User.create(valid_attributes.merge(skip_create_driver: true))
      }.not_to change(Driver, :count)
    end

    it 'should copy name of user to driver' do
      u = User.create valid_attributes
      expect(u.drivers.last.name).to eq u.name
    end

    it 'should not be possible to assign two drivers with the same company_id' do
      u = User.create valid_attributes
      expect {
        u.drivers << create(:driver)
      }.not_to raise_error
    end

  end

  describe '#owns_company' do
    let(:company) { create(:company) }
    subject { create(:user) }

    it 'should return true if its owner of a company' do
      CompanyMember.create(user: subject, company: company, role: CompanyMember::OWNER)
      expect(subject.owens_company).to be_truthy
    end

    it 'should return false if administrates company' do
      CompanyMember.create(user: subject, company: company, role: CompanyMember::ADMINISTRATOR)
      expect(subject.owens_company).to be_falsey
    end

    it 'should return false if no company' do
      expect(subject.owens_company).to be_falsey
    end

  end


end
