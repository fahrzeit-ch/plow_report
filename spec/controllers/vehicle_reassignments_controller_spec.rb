require 'rails_helper'

RSpec.describe VehicleReassignmentsController, type: :controller do

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #create" do
    it "returns http success" do
      get :create
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #prepare" do
    it "returns http success" do
      get :prepare
      expect(response).to have_http_status(:success)
    end
  end

end
