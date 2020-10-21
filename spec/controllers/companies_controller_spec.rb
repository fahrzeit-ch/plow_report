require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:company_registration) }
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

    it 'does not create driver by default' do
      expect {
        post :create, params: {company_registration: valid_attributes}
      }.not_to change(Driver, :count)
    end
  end

  describe 'GET #edit' do
    let(:company) { create(:company) }
    before {
      company.add_member(user, CompanyMember::OWNER)
    }
    it 'returns http success' do
      get :edit, params: { id: company.to_param }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    let(:company) { create(:company) }
    let(:new_attributes) { Hash[valid_attributes.map{|k,str| [k,"new_#{str}"] }] }


    before {
      company.add_member(user, CompanyMember::OWNER)
    }

    it 'returns http success' do
      put :update, params: {id: company.to_param }.merge(company: new_attributes)
      expect(response).to redirect_to company_dashboard_path(company)
    end

    describe 'changed attributes' do
      subject do
        lambda do
          put :update, params: {id: company.to_param}.merge(company: new_attributes)
          company.reload
        end
      end

      it { is_expected.to change(company, :name) }
      it { is_expected.to change(company, :address) }
      it { is_expected.to change(company, :contact_email) }
      it { is_expected.to change(company, :zip_code) }
      it { is_expected.to change(company, :city) }
    end

  end

  describe 'DELETE #destroy' do
    let(:company) { create(:company) }
    before {
      company.add_member(user, CompanyMember::OWNER)
      delete :destroy, params: { id: company.to_param }
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
