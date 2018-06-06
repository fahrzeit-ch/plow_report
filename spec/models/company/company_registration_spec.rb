require 'rails_helper'

RSpec.describe Company::Registration do

  let(:user) { create(:user) }

  describe '#create' do

    subject { Company::Registration.new(name: 'Test',
                                                   contact_email: 'test@test.com',
                                                   add_owner_as_driver: true,
                                                   owner: user,
                                                   transfer_private_drives: false ) }

    it 'should return a registration result' do
      expect(subject.create).to be_a Company::RegistrationResult
    end

    it 'should create a company' do
      res = subject.create
      expect(res.company).to be_persisted
    end

    it 'should add owner as company owner' do
      res = subject.create
      expect(res.company.users).to include(user)
    end

    context 'without add_as_driver' do
      before { subject.add_owner_as_driver = false }

      it 'company should have no drivers' do
        res = subject.create
        expect(res.company.drivers).to be_empty
      end
    end

    context 'add_owner_as_driver' do
      before { subject.add_owner_as_driver = true }

      it 'should create a new driver for the owner' do
        expect {
          subject.create
        }.to change(user.drivers, :count).by 1
      end

      it 'should add the driver to the company' do
        res = subject.create
        expect(user.drivers.last.company).to eq(res.company)
      end
    end

    context 'transfer private drives' do
      before do
        subject.add_owner_as_driver = true
        subject.transfer_private_drives = true
      end

      it 'should not create a new driver' do
        expect {
          subject.create
        }.not_to change(user.drivers, :count)
      end

      it 'should assign the users default driver to the company' do
        res = subject.create
        expect(user.drivers.first.company).to eq(res.company)
      end
    end

  end

end