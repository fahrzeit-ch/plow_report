require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:company) }
  before { sign_in user }

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'returns http success' do
      post :create, params: {company_registration: valid_attributes}
      expect(response).to redirect_to company_dashboard_path(Company.last)
    end
  end

  describe 'GET #edit' do
    let(:company) { create(:company) }
    before {
      company.add_member(user, CompanyMember::OWNER)
    }
    it 'returns http success' do
      get :edit, params: { id: company.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    let(:company) { create(:company) }
    before {
      company.add_member(user, CompanyMember::OWNER)
    }

    it 'returns http success' do
      put :update, params: {id: company.id }.merge(company: valid_attributes)
      expect(response).to redirect_to root_path
    end
  end

  describe 'DELETE #destroy' do
    let(:company) { create(:company) }
    before {
      company.add_member(user, CompanyMember::OWNER)
      delete :destroy, params: { id: company.id }
    }

    it 'returns http success' do
      expect(response).to redirect_to(root_path)
    end

    it 'removes the company from the database' do
      expect {
        company.reload
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

end
