require 'rails_helper'

RSpec.describe CompanyPolicy do

  subject { described_class.new(user, company) }
  let(:company) { create(:company) }

  let(:resolved_scope) do
    described_class::Scope.new(user, Company).resolve
  end

  let(:user) { create(:user) }

  context 'signed in user' do
    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
  end

  context 'company owner' do
    before { company.add_member(user, CompanyMember::OWNER) }

    it { is_expected.to permit_edit_and_update_actions }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
  end

  context 'company administrator' do
    before { company.add_member(user, CompanyMember::ADMINISTRATOR) }

    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
  end

  context 'company driver' do
    before { company.add_member(user, CompanyMember::DRIVER) }

    it { is_expected.to forbid_edit_and_update_actions }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_new_and_create_actions }
  end
end
