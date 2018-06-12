require 'rails_helper'

RSpec.describe Company::CompanyMembersController, type: :controller do
  let(:company_admin) { create(:user, skip_create_driver: true) }
  let(:company) { create(:company) }

  before do
    company.add_member(company_admin, CompanyMember::ADMINISTRATOR)
    sign_in(company_admin)
  end

  describe '#post resend_invitation' do
    let(:invited_user) { build(:company_member_invite, company: company) }
    before { invited_user.save_and_invite!(company_admin) }
    it 'should send email' do
      expect {
        post :resend_invitation, params: { company_id: company.id, id: invited_user.id, format: :js }
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  describe '#delete destroy' do
    let(:driver_user) { create(:user, skip_create_driver: true) }
    let(:member) { company.add_member(driver_user, CompanyMember::DRIVER) }

    it 'should remove the member from the company' do
      delete :destroy, params: { company_id: company.id, id: member.id }
      company.reload
      expect(company.company_members).not_to include(member)
    end

    it 'should remove driver association' do
      delete :destroy, params: { company_id: company.id, id: member.id }
      driver_user.reload
      expect(driver_user.drivers).to be_empty
    end

    it 'should keep the driver record for the company' do
      delete :destroy, params: { company_id: company.id, id: member.id }
      company.reload
      expect(company.drivers.count).to eq(1)
    end
  end
end
