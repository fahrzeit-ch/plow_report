# frozen_string_literal: true

require "rails_helper"

RSpec.describe DriverApplicationsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user) }
  let(:company) { create(:company) }

  before { company.add_member(admin, CompanyMember::ADMINISTRATOR) }

  describe "GET #create" do
    before { sign_in user }

    it "returns http success" do
      post :create, params: { driver_application: { recipient: admin.email } }
      expect(response).to redirect_to(driver_application_path(DriverApplication.last))
    end

    it "creates a driver application" do
      post :create, params: { driver_application: { recipient: admin.email } }
      expect(DriverApplication.count).to eq(1)
    end
  end

  describe "GET #review" do
    before { sign_in admin }
    let(:application) { create(:driver_application) }

    it "returns http not authorized" do
      get :review, params: { id: application.token }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #accept" do
    let(:application) { create(:driver_application, user: user) }

    context "without administrator access to company" do
      let(:non_admin) { create(:user) }
      before do
        company.add_member(non_admin, CompanyMember::DRIVER)
        sign_in(non_admin)
      end
      it "returns http success" do
        patch :accept, params: { id: application.token, driver_application: { assign_to_id: company.id } }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with administrator access to company" do
      before { sign_in admin }

      it "returns http success" do
        patch :accept, params: { id: application.token, driver_application: { assign_to_id: company.id }  }
        expect(response).to redirect_to(company_drivers_path(company))
      end

      it "adds the user as driver to company" do
        post :accept, params: { id: application.token, driver_application: { assign_to_id: company.id } }
        user.reload
        expect(user.drives_for?(company)).to be_truthy
      end
    end
  end
end
