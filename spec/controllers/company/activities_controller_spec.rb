require 'rails_helper'

RSpec.describe Company::ActivitiesController, type: :controller do
  let(:user) { create(:user) }

  let(:company) { create(:company) }
  let(:activities) { create_list(:activity, 3, company: company) }

  before do
    company.add_member(user, CompanyMember::DRIVER)
    sign_in user
  end

  describe 'GET #index' do
    context 'as company admin' do
      before do
        CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR)
      end

      it 'returns http success' do
        get :index, params:{ company_id: company.id }
        expect(response).to have_http_status(:success)
      end

    end

    context 'as non company member' do
      let(:other_company) { create(:company) }

      it 'redirects to root page' do
        get :index, params: { company_id: other_company.id }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'POST Create' do

    subject { response }

    context 'as non admin' do
      before {post :create, params: {company_id: company.id, activity: attributes_for(:activity)} }

      it 'redirects to root (because of not authorized error)' do
        expect(response).to redirect_to(root_path)
      end

      it 'does not create activity' do
        expect(Activity.all.count).to be 0
      end
    end

    context 'as admin' do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }

      before {post :create, params: {company_id: company.id, activity: attributes_for(:activity)} }

      it { is_expected.to be_redirect }
      it 'creates new activity' do
        expect(Activity.all.count).to be 1
      end
    end
  end

  describe 'GET #destroy' do
    context 'as non admin' do
      it 'redirects to root (because of not authorized error)' do
        delete :destroy, params:{ company_id: company.id, id: activities.first.id }
        expect(response).to redirect_to(root_path)
      end

      it 'does not destroy activity' do
        delete :destroy, params:{ company_id: company.id, id: activities.first.id }
        expect(Activity.all.count).to be 3
      end
    end

    context 'as admin' do

      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }
      it 'returns http success' do
        delete :destroy, params:{ company_id: company.id, id: activities.first.id }
        expect(response).to redirect_to(company_activities_path company)
      end

      it 'destroys activity' do
        delete :destroy, params:{ company_id: company.id, id: activities.first.id }
        expect(Activity.all.count).to be 2
      end
    end

  end

  describe '#PUT update' do
    let(:activity) { activities.last }
    let(:new_attrs) { attributes_for(:activity, name: 'new name') }

    context 'as admin' do
      before { CompanyMember.last.update(role: CompanyMember::ADMINISTRATOR) }

      it 'updates the activity' do
        put :update, params: { id: activity.id, company_id: company.id, activity: new_attrs }
        activity.reload
        expect(activity.name).to eq new_attrs[:name]
      end
    end
  end

end
