require 'rails_helper'

RSpec.describe Company::DrivesController, type: :controller do
  let(:user) { create(:user) }
  before { sign_in user }

  let(:company) { create(:company) }
  let(:drives) { create_list(:drive, 3, driver: create(:driver, company_id: company.id)) }

  describe "GET #index" do
    it "returns http success" do
      get :index, params:{ company_id: company.id }
      expect(response).to have_http_status(:success)
    end

    it 'accepts driver id scope' do
      get :index, params: { company_id: company.id, driver_id: 12 }
    end
  end

  describe "GET #destroy" do
    it "returns http success" do
      get :destroy, params:{ company_id: company.id, id: drives.first.id }
      expect(response).to redirect_to(company_drives_path company)
    end
  end

end
