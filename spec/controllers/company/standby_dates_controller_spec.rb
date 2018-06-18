require 'rails_helper'

RSpec.describe Company::StandbyDatesController, type: :controller do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:driver) { create(:driver, user: user, company: company) }

  before do
    sign_in user
    company.add_member(user, CompanyMember::ADMINISTRATOR)
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params:{ company_id: company.id }
      expect(response).to have_http_status(:success)
    end

    it 'accepts driver id scope' do
      get :index, params: { company_id: company.id, driver_id: 12 }
    end
  end

  describe 'POST #create' do
    let(:standby_params) { {standby_date: { driver_id: driver.id, day: Date.today }} }
    subject { post :create, params: { company_id: company.id}.merge(standby_params) }

    context 'standby date' do
      it 'redirects back to standby dates' do
        expect(subject).to redirect_to(company_standby_dates_path(company))
      end

      it 'creates a new standby date' do
        expect {
          subject
        }.to change(StandbyDate, :count).by(1)
      end
    end

    context 'date range' do
      let(:standby_params) { {standby_date_date_range: {driver_id: driver.id, start_date: Date.yesterday, end_date: Date.today}} }
      it 'redirects back to standby dates' do
        expect(subject).to redirect_to(company_standby_dates_path(company))
      end

      it 'creates a new standby date' do
        expect {
          subject
        }.to change(StandbyDate, :count).by(2)
      end
    end

  end

end