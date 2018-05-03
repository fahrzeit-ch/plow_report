require 'rails_helper'

RSpec.describe DrivesController, type: :controller do

  let(:user) { create(:user) }

  describe 'GET #index' do

    subject { response }

    context 'signed out' do
      it 'should redirect to login' do
        get :index
        expect(subject).to redirect_to '/users/sign_in'
      end
    end

    context 'signed in' do
      before { sign_in user }

      it 'should be successful' do
        get :index
        expect(subject).to be_success
      end
    end
  end

  describe 'GET #suggested_km' do
    subject { response }
    context 'signed in' do
      before do
        sign_in user
        create(:drive, driver: user.drivers.first, salt_refilled: true, salt_amount_tonns: 10.0)
      end

      context 'no similar drives' do
        it 'be successful' do
          get :suggested_values, params: { salted: true, format: :json }
          expect(subject).to be_success
        end
      end
    end

  end

  describe 'POST #create' do
    let(:valid_params) { attributes_for(:drive) }

    context 'signed out' do

      it 'should redirect to login' do
        post :create, params: valid_params
        expect(subject).to redirect_to '/users/sign_in'
      end

    end

    context 'signed in' do

      before { sign_in user }

      context 'with valid attributes' do

        it 'should redirect to index page' do
          post :create, params: { drive: valid_params }
          expect(subject.status).to redirect_to '/drives'
        end

        it 'should create drive with the users driver' do
          expect {
            post :create, params: { drive: valid_params }
          }.to change(Drive.where(driver: user.drivers.last), :count)
        end

      end

    end
  end

end
