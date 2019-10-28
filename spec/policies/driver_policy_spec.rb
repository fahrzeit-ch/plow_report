require 'rails_helper'

RSpec.describe DriverPolicy, type: :model do
  subject { described_class.new(user, driver) }
  let(:company) { create(:company) }

  let!(:driver) { create(:driver, company: company) }
  let!(:personal_driver) { create(:driver, user: user) }

  let(:resolved_scope) do
    described_class::Scope.new(user, Driver.all).resolve
  end

  let(:user) { create(:user) }

  describe 'scope' do
    subject { resolved_scope }

    context 'without company assignement' do
      it { is_expected.to include(personal_driver) }
      it { is_expected.not_to include(driver) }
    end

    context 'with company assignment as admin' do
      before do
        company.add_member(user, CompanyMember::ADMINISTRATOR)
      end

      it { is_expected.to include(personal_driver) }
      it { is_expected.to include(driver) }
    end

    context 'with company assignment as admin' do
      before do
        company.add_member(user, CompanyMember::OWNER)
      end

      it { is_expected.to include(personal_driver) }
      it { is_expected.to include(driver) }
    end

    context 'with company assignment as admin' do
      let!(:own_company_driver) { company.add_driver(user)[:driver] }

      before do
        company.add_member(user, CompanyMember::DRIVER)
      end

      it { is_expected.to include(personal_driver) }
      it { is_expected.not_to include(driver) }
      it { is_expected.to include(own_company_driver) }

    end
  end

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
