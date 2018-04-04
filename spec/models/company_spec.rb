require 'rails_helper'

RSpec.describe Company, type: :model do

  let(:valid_attributes) { attributes_for(:company) }

  describe 'validation' do

    context 'valid attributes' do
      subject { described_class.new valid_attributes }

      it 'should be valid' do
        expect(subject).to be_valid
      end

      it 'should not be valid without an email address' do
        subject.contact_email = ''
        expect(subject).not_to be_valid
      end

      it 'should not be valid with blank name' do
        subject.name = ''
        expect(subject).not_to be_valid
      end

      it 'should not be valid with a company name that already exists' do
        create(:company, valid_attributes)
        expect(subject).not_to be_valid
      end

      it 'should be valid when options are set to nil' do
        subject.options = nil
        expect(subject).to be_valid
      end

    end

  end

  describe '#drivers' do
    subject { create(:company) }
    let(:driver) { create(:driver) }
    it 'should be possible to associate a driver' do
      expect {
        subject.drivers << driver
      }.to change(driver, :company)
    end



  end

  describe '#drives' do
    subject { create(:company) }
    # create driver associated to the company
    let(:company_driver) { create(:driver, company: subject) }
    let(:other_driver) { create(:driver, company: create(:company)) }
    let(:private_driver) { create(:driver) }

    let(:company_drive) { create(:drive, driver: company_driver) }
    let(:other_drive) { create(:drive, driver: other_driver) }
    let(:private_drive) { create(:drive, driver: private_driver) }

    it 'should include only drives of drivers associated to the company' do
      expect(subject.drives).to include(company_drive)
      expect(subject.drives).not_to include(other_drive, private_drive)
    end
  end

  describe 'options' do
    subject { described_class.new valid_attributes }

    it 'should be possible to persist an options hash to the company' do
      subject.options = { test_value: 'some string' }
      subject.save!
      subject.reload
      expect(subject.options).to eq 'test_value' => 'some string'
    end

  end

  describe 'with_member' do
    let(:user) { create(:user) }
    let(:company1) { create(:company) }
    let(:company2) { create(:company) }
    let(:company3) { create(:company) }

    before do
      # create memeberships
      create(:company_member, user: user, company: company1)
      create(:company_member, user: user, company: company2)
      create(:company_member, company: company3)
    end

    it 'should scope to all companies containing a membership for the given user id' do
      expect(Company.with_member(user.id)).to include(company1, company2)
    end
  end
end