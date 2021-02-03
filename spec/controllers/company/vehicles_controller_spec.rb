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

    it "creates a new vehicle" do
      expect {
        post :create, params: { company_id: company.to_param, vehicle: attributes_for(:vehicle) }
      }.to change(Vehicle, :count).by(1)
    end

    describe "activities and price rates" do
      let(:activity) { create(:activity, company: company) }
      let(:activity_assignment_attributes) { { activity_id: activity.id, hourly_rate_attributes: { price: "80.0", valid_from: 1.year.ago.to_s } } }
      let(:vehicle_attributes) { attributes_for(:vehicle).merge(vehicle_activity_assignments_attributes: { 1 => activity_assignment_attributes }) }

      it "it creates an activity asignment" do
        expect {
          post :create, params: { company_id: company.to_param, vehicle: vehicle_attributes }
        }.to change(VehicleActivityAssignment, :count).by(1)
      end

      it "it creates an activity asignment" do
        expect {
          post :create, params: { company_id: company.to_param, vehicle: vehicle_attributes }
        }.to change(Pricing::HourlyRate, :count).by(1)
      end
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
