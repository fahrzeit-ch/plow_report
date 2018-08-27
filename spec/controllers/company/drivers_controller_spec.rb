require 'rails_helper'
RSpec.describe Company::DriversController, type: :controller do

  let(:company) { create(:company) }
  let(:company_admin) { create(:user) }

  before { company.add_member company_admin, CompanyMember::OWNER }

  before { sign_in(company_admin) }

  describe 'POST #update' do
    let(:driver) { create(:driver, company: company) }
    let(:other_member) { create(:company_member, company: company, role: :owner) }
    let(:params) { { driver: { user: other_member.user.id }, company_id: company.id, id: driver.id } }

    before { post :update, params: params }

    context 'to driver without user' do
      it { expect(response).to redirect_to(company_drivers_path(company)) }
      it { expect(driver.user).to eq(other_member.user) }
    end

    context 'to driver with assigned user' do
      let(:driver) { create(:driver, company: company, user: create(:user)) }

      it { expect(response.status).to eq 422 }
    end

    context 'with user not in company' do
      let(:other_company) { create(:company) }
      let(:other_member) { create(:company_member, company: other_company, role: :owner) }

      it { expect(response.status).to eq 422 }
    end

    context 'with user that already is assigned to a driver in company' do
      let(:other_member) { create(:company_member, company: company, role: :driver) }

      it { expect(response.status).to eq 422 }
    end

  end


end