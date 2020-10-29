# frozen_string_literal: true

require "rails_helper"

RSpec.describe HourlyRate, type: :model do
  let(:company) { create(:company) }
  let(:customer) { create(:customer, client_of: company) }
  let(:activity) { create(:activity, company: company) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:company) }

    describe "valida"

    describe "uniqueness" do
      subject { existing.dup }

      context "default_company_rate" do
        let(:existing) { create(:hourly_rate, company: company, activity: nil, customer: nil, valid_from: 1.day.ago, valid_until: 1.day.from_now, price: Money.new(1000)) }
        it { is_expected.not_to be_valid }
      end
      context "default_activity_rate" do
        let(:existing) { create(:hourly_rate, company: company, activity: activity, customer: nil, valid_from: 1.day.ago, valid_until: 1.day.from_now, price: Money.new(1000)) }
        it { is_expected.not_to be_valid }
      end
      context "default_customer_rate" do
        let(:existing) { create(:hourly_rate, company: company, activity: nil, customer: customer, valid_from: 1.day.ago, valid_until: 1.day.from_now, price: Money.new(1000)) }
        it { is_expected.not_to be_valid }
      end
      context "explicit_rate" do
        let(:existing) { create(:hourly_rate, company: company, activity: activity, customer: customer, valid_from: 1.day.ago, valid_until: 1.day.from_now, price: Money.new(1000)) }
        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "scopes" do
    let(:activity2) { create(:activity, company: company) }
    let(:customer2) { create(:customer, company: company) }

    let(:base_price) { create(:hourly_rate, customer: nil, company: company, activity: nil) }
    let(:activity1_price) { create(:hourly_rate, customer: nil, company: company, activity: activity) }

    let(:customer_base_price) { create(:hourly_rate, customer: customer, company: company, activity: nil) }
    let(:customer_activity2_price) { create(:hourly_rate, customer: customer, company: company, activity: activity2) }

    let(:customer2_activity1_price) { create(:hourly_rate, customer: customer, company: company, activity: activity) }

    let!(:company_rates) { [base_price, activity1_price, customer_base_price, customer_activity2_price, customer2_activity1_price] }


    describe "children" do
      subject { base_price.children }
      it { is_expected.to include(activity1_price, customer_base_price, customer_activity2_price, customer2_activity1_price) }
      it { is_expected.not_to include(base_price) }

      describe "children of child" do
        subject { activity1_price.children }
        it { is_expected.to be_empty }
      end
    end

    describe "base_price" do
      subject { HourlyRate.base_rate }
      it { is_expected.to eq(base_price) }
    end

    describe "activity_rates" do
      subject { HourlyRate.activity_rates }
      it { is_expected.to include(activity1_price) }
      its(:size) { is_expected.to eq 1 }
    end
  end

  describe "auditing" do
    let(:audited_model) { create(:hourly_rate, company: company, customer: customer, activity: activity) }
    before { audited_model.update_attributes!(price: (audited_model.price * 2)) }

    subject { audited_model.audits.last }

    its(:action) { is_expected.to eq "update" }
  end

  describe "deletion" do
    let!(:base_price) { create(:hourly_rate, customer: nil, company: company, activity: nil) }
    let!(:activity1_price) { create(:hourly_rate, customer: nil, company: company, activity: activity) }

    subject { base_price.destroy_children }

    it "destroys related prices" do
      expect {
        subject
        activity1_price.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not destroy self" do
      expect {
        subject
        base_price.reload
      }.not_to raise_error
    end
  end
end
