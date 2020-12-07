# frozen_string_literal: true

require "rails_helper"

RSpec.describe Company::VehiclesController, type: :controller do
  let(:company) { create(:company) }
  let(:company_admin) { create(:user) }

  before { company.add_member company_admin, CompanyMember::OWNER }
  before { sign_in(company_admin) }

  describe "GET #index" do
    it "returns http success" do
      get :index, params: { company_id: company.to_param }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "redirects to index page" do
      post :create, params: { company_id: company.to_param, vehicle: attributes_for(:vehicle) }
      expect(response).to redirect_to(company_vehicles_path company)
    end
  end

  describe "GET #edit" do
    let!(:vehicle) { create(:vehicle, company: company) }

    it "returns http success" do
      get :edit, params: { company_id: company.to_param, id: vehicle.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    let!(:vehicle) { create(:vehicle, company: company) }

    it "redirects back to index" do
      patch :update, params: { company_id: company.to_param, id: vehicle.id, vehicle: attributes_for(:vehicle) }
      expect(response).to redirect_to(company_vehicles_path company)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new, params: { company_id: company.to_param }
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE #destroy" do
    let!(:vehicle) { create(:vehicle, company: company) }
    it "returns http success" do
      delete :destroy, params: { company_id: company.to_param, id: vehicle.id }
      expect(response).to redirect_to(company_vehicles_path company)
    end
  end
end
