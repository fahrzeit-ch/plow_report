require 'rails_helper'

RSpec.describe DrivePolicy do

  subject { described_class.new(user, drive) }
  let(:company) { create(:company) }

  let(:resolved_scope) do
    described_class::Scope.new(user, Drive.all).resolve
  end

  let(:user) { create(:user) }

  describe 'own drives' do
    let(:drive) { create(:drive, driver: create(:driver, user: user)) }

    context 'signed in user' do
      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_new_and_create_actions }
    end

  end

  describe 'company drives' do
    let(:other_driver) { create(:driver, company: company) }
    let(:drive) { build(:drive, driver: other_driver) }

    context 'non company member' do
      it { is_expected.to permit_action(:index) } # index is always allowed as it is not bound to single record
      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to forbid_action(:show) }
      it { is_expected.to permit_action(:new) }
      it { is_expected.to forbid_action(:edit) }
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

      it { is_expected.to permit_edit_and_update_actions }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_new_and_create_actions }
    end

    context 'company driver' do
      before { company.add_member(user, CompanyMember::DRIVER) }

      it { is_expected.to forbid_edit_and_update_actions }
      it { is_expected.to forbid_action(:destroy) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to forbid_action(:create) }
      it { is_expected.to permit_action(:new) }
    end

  end
end
