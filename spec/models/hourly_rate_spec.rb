require 'rails_helper'

RSpec.describe HourlyRate, type: :model do

  let(:company) { create(:company) }
  let(:customer) { create(:customer) }
  let(:activity) { create(:activity, company: company) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:company) }

    describe 'uniqueness' do

      subject { existing.dup }

      context 'default_company_rate' do
        let(:existing) { create(:hourly_rate, company: company, activity: nil, customer: nil, valid_from: 1.day.ago, valid_until: 1.day.from_now, price: Money.new(1000)) }
        it { is_expected.not_to be_valid }
      end
      context 'default_activity_rate' do
        let(:existing) { create(:hourly_rate, company: company, activity: activity, customer: nil, valid_from: 1.day.ago, valid_until: 1.day.from_now, price: Money.new(1000)) }
        it { is_expected.not_to be_valid }
      end
      context 'default_customer_rate' do
        let(:existing) { create(:hourly_rate, company: company, activity: nil, customer: customer, valid_from: 1.day.ago, valid_until: 1.day.from_now, price: Money.new(1000)) }
        it { is_expected.not_to be_valid }
      end
      context 'explicit_rate' do
        let(:existing) { create(:hourly_rate, company: company, activity: activity, customer: customer, valid_from: 1.day.ago, valid_until: 1.day.from_now, price: Money.new(1000)) }
        it { is_expected.not_to be_valid }
      end
    end
  end

  describe 'auditing' do
    let(:audited_model) { create(:hourly_rate, company: company, customer: customer, activity: activity) }
    before { audited_model.update_attributes!(price: (audited_model.price * 2)) }

    subject { audited_model.audits.last }

    its(:action) { is_expected.to eq 'update' }
  end


end
