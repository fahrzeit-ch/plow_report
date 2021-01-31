# frozen_string_literal: true

require "rails_helper"
RSpec.describe Company::DriversController, type: :controller do
  let(:company) { create(:company) }
  let(:company_admin) { create(:user) }

  before { company.add_member company_admin, CompanyMember::OWNER }

  before { sign_in(company_admin) }

  describe "PATCH #update" do
    let(:driver) { create(:driver, company: company) }
    let(:other_member) { create(:company_member, company: company, role: :owner) }
    let(:params) { { driver: { user: other_member.user.id }, company_id: company.id, id: driver.id } }

    before { patch :update, params: params }

    context "to driver without user" do
      it { expect(response).to redirect_to(company_drivers_path(company)) }
      it { expect(driver.user).to eq(other_member.user) }
    end

    context "to driver with assigned user" do
      let(:driver) { create(:driver, company: company, user: create(:user)) }

      it { expect(response.status).to eq 422 }
    end

    context "with user not in company" do
      let(:other_company) { create(:company) }
      let(:other_member) { create(:company_member, company: other_company, role: :owner) }

      it { expect(response.status).to eq 422 }
    end

    context "with user that already is assigned to a driver in company" do
      let(:other_member) { create(:company_member, company: company, role: :driver) }

      it { expect(response.status).to eq 422 }
    end
  end

  describe "POST #create" do
    let(:other_member) { create(:company_member, company: company, role: :owner) }
    let(:params) { { driver: { name: "Hans" }, company_id: company.id } }

    before { post :create, params: params }

    it { expect(response).to redirect_to company_drivers_path(company) }
    it { expect(Driver.where(name: "Hans", company_id: company.id).count).to eq(1) }
  end

  describe "DELETE #destroy" do
    let(:other_member) { create(:company_member, company: company, role: :owner) }
    let(:driver) { create(:driver, company: company) }

    context "without drives" do
      before { delete :destroy, params: { id: driver.id, company_id: company.to_param } }

      it { expect(response).to redirect_to company_drivers_path(company) }
      it { expect(Driver.find_by(id: driver.id)).to be_nil }
    end

    context "with existing drives" do
      before { create(:drive, driver: driver) }
      before { delete :destroy, params: { id: driver.id, company_id: company.to_param } }

      it { expect(response).to redirect_to company_drivers_path(company) }
      it { expect(Driver.find_by(id: driver.id)).to be_nil }
    end

    context "with existing tour" do
      let(:tour) { create(:tour) }
      before do
        create(:drive, driver: driver, tour: tour)
      end

      before { delete :destroy, params: { id: driver.id, company_id: company.to_param } }

      it { expect(response).to redirect_to company_drivers_path(company) }
      it { expect(Driver.find_by(id: driver.id)).to be_nil }
    end

    context "with discarded tours" do
      let(:tour) { create(:tour) }
      before do
        create(:drive, driver: driver, tour: tour)
        tour.discard
      end

      before { delete :destroy, params: { id: driver.id, company_id: company.to_param } }

      it { expect(response).to redirect_to company_drivers_path(company) }
      it { expect(Driver.find_by(id: driver.id)).to be_nil }
    end
  end
end
