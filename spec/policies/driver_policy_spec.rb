require 'rails_helper'

RSpec.describe DriverPolicy do
  subject { described_class.new(user, driver) }
  let(:company) { create(:company) }

  let(:driver) { build(:driver, company: company) }

  let(:resolved_scope) do
    described_class::Scope.new(user, Company).resolve
  end

  let(:user) { create(:user) }

  context 'as signed in user' do
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_new_and_create_actions }
  end

  context 'as personal driver' do
    before { driver.company = nil }
    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
  end

  context 'as company owner' do
    before { company.add_member(user, CompanyMember::OWNER) }

    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
  end

  context 'as company administrator' do
    before { company.add_member(user, CompanyMember::ADMINISTRATOR) }

    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
  end

  context 'as company driver' do
    before { company.add_member(user, CompanyMember::DRIVER) }

    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_new_and_create_actions }
  end

  context 'as other company administrator' do
    let(:other_company) { create(:company) }
    before { other_company.add_member(user, CompanyMember::ADMINISTRATOR) }

    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_new_and_create_actions }
  end
end
