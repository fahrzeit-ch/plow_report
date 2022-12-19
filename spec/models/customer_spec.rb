# frozen_string_literal: true

require "rails_helper"

RSpec.describe Customer, type: :model do
  subject { build(:customer) }

  context "if company name empty" do
    before { allow(subject).to receive(:company_name_blank?).and_return(true) }
    it "validates name" do
      subject.name = ""
      expect(subject).not_to be_valid
    end
  end

  context "if name empty" do
    before { allow(subject).to receive(:name_blank?).and_return(true) }
    it do
      subject.company_name = ""
      expect(subject).not_to be_valid
    end
  end

  it { is_expected.to belong_to(:client_of) }

  describe "#destroy" do
    let(:customer) { create(:customer) }
    subject { customer.destroy }
    context "without tracked drives" do
      it { is_expected.to be_truthy }
    end

    context "wihth existing drives" do
      before { create(:drive, customer: customer) }
      it { is_expected.to be_falsey }
    end
  end

  describe "#with_site_names" do
    let(:customer) { create(:customer) }
    let!(:sites) { create_list(:site, 2, customer: customer) }

    subject { described_class.with_site_names.first }
    its(:site_names) { is_expected.to eq(sites.pluck(:display_name).join(', ')) }

    context "inactive sites" do
      before { sites.first.update(active: false) }
      its(:site_names) { is_expected.to eq(sites.last.display_name )}
    end
  end

  describe "ordering" do
    let(:company) { create(:company) }
    let!(:customer1) { create(:customer, company_id: company.id, name: "A", company_name: "") }
    let!(:customer2) { create(:customer, company_id: company.id, name: "B", company_name: "") }
    let!(:customer3) { create(:customer, company_id: company.id, name: "C", company_name: "A") }
    let!(:customer4) { create(:customer, company_id: company.id, name: "Z", company_name: "A") }
    let!(:customer5) { create(:customer, company_id: company.id, name: "D", company_name: "") }

    subject { described_class.order_by_name.all }
    it "sorts alphabetically" do
      expect(subject[0]).to eq(customer1) # A
      expect(subject[1]).to eq(customer3)
      expect(subject[2]).to eq(customer4)
      expect(subject[3]).to eq(customer2)
      expect(subject[4]).to eq(customer5)
    end
  end
end
