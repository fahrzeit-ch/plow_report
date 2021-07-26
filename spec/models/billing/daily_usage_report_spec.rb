# frozen_string_literal: true

require "rails_helper"

RSpec.describe Billing::DailyUsageReport, type: :model do
  let(:company) { create(:company) }
  let(:driver) { create(:driver, company: company) }

  context "company without data" do
    subject { described_class.where(company_id: company.id) }
    it { is_expected.to be_empty }
  end

  context "with drives" do
    let(:tour) { create(:tour, driver: driver) }
    let!(:drive) { create(:drive, driver: driver, tour: tour) }
    subject { described_class.where(company_id: company.id) }

    its(:count) { is_expected.to eq 1 }
  end

  context "same site on one tour" do
    let(:tour) { create(:tour, driver: driver) }
    let(:site1) { create(:site, customer: create(:customer, client_of: company))}

    let!(:drive) { create(:drive, driver: driver, tour: tour, site: site1) }
    let!(:drive) { create(:drive, driver: driver, tour: tour, site: site1) }

    subject { described_class.where(company_id: company.id).first }

    its(:nr_of_drives) { is_expected.to eq 1 }
    its(:nr_of_tours) { is_expected.to eq 1 }
    its(:date_trunc) { is_expected.to eq tour.start_time.to_date }
  end

  context "same site on different tour" do
    let(:tour1) { create(:tour, driver: driver) }
    let(:tour2) { create(:tour, driver: driver) }
    let(:site1) { create(:site, customer: create(:customer, client_of: company))}

    let!(:drive1) { create(:drive, driver: driver, tour: tour1, site: site1) }
    let!(:drive2) { create(:drive, driver: driver, tour: tour2, site: site1) }

    subject { described_class.where(company_id: company.id).first }

    its(:nr_of_drives) { is_expected.to eq 2 }
    its(:nr_of_tours) { is_expected.to eq 2 }
    its(:date_trunc) { is_expected.to eq tour1.start_time.to_date }
  end

  context "different site at next day on same tour" do
    let(:tour1) { create(:tour, driver: driver) }
    let(:site1) { create(:site, customer: create(:customer, client_of: company))}
    let(:site2) { create(:site, customer: create(:customer, client_of: company))}
    let(:start_time1) { tour1.start_time }
    let(:start_time2) { start_time1 + 1.day}

    let!(:drive1) { create(:drive, start: start_time1, driver: driver, tour: tour1, site: site1) }
    let!(:drive2) { create(:drive, start: start_time2, end: start_time2 + 10.minutes, driver: driver, tour: tour1, site: site2) }

    subject { described_class.where(company_id: company.id).first }

    its(:nr_of_drives) { is_expected.to eq 2 }
    its(:nr_of_tours) { is_expected.to eq 1 }
    its(:date_trunc) { is_expected.to eq tour1.start_time.to_date }
  end

  context "with discarded drives" do
    let(:tour) { create(:tour, driver: driver) }
    let!(:drive) { create(:drive, driver: driver, tour: tour, discarded_at: 1.day.ago) }
    subject { described_class.where(company_id: company.id) }

    it { is_expected.to be_empty }
  end

  context "with discarded tour" do
    let(:driver) { create(:driver, company: company) }
    let(:tour) { create(:tour, driver: driver, discarded_at: 1.day.ago) }
    let!(:drive) { create(:drive, driver: driver, tour: tour) }
    subject { described_class.where(company_id: company.id) }

    it { is_expected.to be_empty }
  end

  context "with drives without sites" do
    let(:driver) { create(:driver, company: company) }
    let(:tour) { create(:tour, driver: driver, discarded_at: 1.day.ago) }
    let!(:drive) { create(:drive, driver: driver, tour: tour) }
    subject { described_class.where(company_id: company.id) }

    it { is_expected.to be_empty }
  end

end
