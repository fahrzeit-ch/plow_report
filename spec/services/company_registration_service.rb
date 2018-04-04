require 'rails_helper'

RSpec.describe CompanyRegistrationService do

  subject { described_class.new nil }

  let(:company) { create(:company) }

  describe '#create_driver' do

    let(:driver_params) { { name: 'hans' } }
    subject { described_class.new(nil).create_company_driver(company, driver_params) }

    it 'should return a driver' do
      expect(subject).to be_a Driver
    end

    it 'should be persisted with valid params' do
      expect(subject).to be_persisted
    end

    context 'invalid params' do
      let(:driver_params) { { name: '' } }

      it 'should not be persisted' do
        expect(subject).not_to be_persisted
      end

    end
  end

  describe '#add_driver' do

    let(:user) { create(:user) }

    context 'with transfer default' do
      subject { described_class.new(nil).add_driver(company, user, true) }

      it 'should return the driver' do
        expect(subject).to be_a Driver
      end

      it 'should not create a new driver' do
        subject
        expect(user.drivers.count).to eq 1
      end

      it 'should assign the driver to the company' do
        expect(subject.company).to eq company
      end

      context 'non existing default driver' do
        before { user.drivers.first.update_attribute(:company_id, create(:company).id) }

        it 'should create a new driver' do
          expect {
            subject
          }.to change(user.drivers, :count).by 1
        end
      end

    end

    context 'without transfer_default' do
      subject { described_class.new(nil).add_driver(company, user, false) }

      it 'should create a new driver' do
        expect {
          subject
        }.to change(user.drivers, :count).by 1
      end

    end




  end


end