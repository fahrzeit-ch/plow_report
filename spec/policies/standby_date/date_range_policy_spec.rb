# frozen_string_literal: true

require "rails_helper"

RSpec.describe StandbyDate::DateRangePolicy do
  subject { described_class.new(user, date_range) }

  let(:date_range) { build(:standby_date_date_range, driver_id: driver.id) }
  let(:user) { create(:user) }
  before { user.create_personal_driver }

  context "for own driver" do
    let(:driver) { user.drivers.first }

    it { is_expected.to permit_action(:create) }
  end

  context "for company admins" do
    let(:company) { create(:company) }
    before { company.add_member(user, CompanyMember::ADMINISTRATOR) }

    context "with driver of same company" do
      let(:driver) { create(:driver, company: company) }

      it { is_expected.to permit_action(:create) }
    end

    context "with driver not in company" do
      let(:driver) { create(:driver) }
      it { is_expected.to forbid_action(:create) }
    end
  end
end
