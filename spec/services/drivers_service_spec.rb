# frozen_string_literal: true

require "rails_helper"

RSpec.describe DriversService do
  subject { described_class.new }

  describe "drivers for" do
    let(:user) { create(:user, skip_create_driver: true) }
    let(:drivers) { create_list(:driver, 2, user: user) }

    context "when no company given" do
      subject { described_class.new.drivers_for(user, nil) }

      it { is_expected.to include(*drivers) }
    end

    context "when company given" do
      let(:company) { create(:company) }
      subject { described_class.new.drivers_for(user, company) }

      context "and user is not member of it" do
        it { is_expected.to be_empty }
      end

      context "and user is of member type sdriver" do
        let!(:company_driver) { company.add_driver(user)[:driver] }
        before { company.add_member(user, CompanyMember::DRIVER) }

        it { is_expected.to include company_driver }
        its(:length) { is_expected.to eq 1 }
      end

      context "and user is company admin" do
        let(:company_drivers) { create_list(:driver, 2, company: company) }
        before { company.add_member(user, CompanyMember::ADMINISTRATOR) }

        it { is_expected.to include(*company_drivers) }
      end
    end
  end
end
