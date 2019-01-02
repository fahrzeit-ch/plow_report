require 'rails_helper'

RSpec.describe Company::DrivesController, type: :controller do
  let(:user) { create(:user) }

  let(:company) { create(:company) }
  let(:drives) { create_list(:drive, 3, driver: create(:driver, company_id: company.id)) }

  before do
    company.add_member(user, CompanyMember::DRIVER)
    sign_in user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params:{ company_id: company.to_param }
      expect(response).to have_http_status(:success)
    end

    it 'accepts driver id scope' do
      get :index, params: { company_id: company.to_param, driver_id: 12 }
    end

    context 'as non company member' do
      let(:other_company) { create(:company) }

      it 'redirects to root page' do
        get :index, params: { company_id: other_company.to_param }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET #destroy' do
    context 'as non admin' do
      it 'redirects to root (because of not authorized error)' do
        delete :destroy, params:{ company_id: company.to_param, id: drives.first.id }
        expect(response).to redirect_to(root_path)
      end

      it 'does not destroy drive' do
        delete :destroy, params:{ company_id: company.to_param, id: drives.first.id }
        expect(Drive.all.count).to be 3
      end
    end

    context 'as admin' do

      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }
      it 'returns http success' do
        delete :destroy, params:{ company_id: company.to_param, id: drives.first.id }
        expect(response).to redirect_to(company_drives_path company)
      end

      it 'destroys drive' do
        delete :destroy, params:{ company_id: company.to_param, id: drives.first.id }
        expect(Drive.all.count).to be 2
      end
    end

  end

  describe '#PUT update' do
    let(:drive) { drives.last }
    let(:new_attrs) { attributes_for(:drive, distance_km: 500) }

    context 'as admin' do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }

      it 'updates the drive' do
        put :update, params: { id: drive.id, company_id: company.to_param, drive: new_attrs }
        drive.reload
        expect(drive.distance_km).to eq 500
      end
    end
  end

end
