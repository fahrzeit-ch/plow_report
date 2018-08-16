require 'rails_helper'

RSpec.describe User::RegistrationsController, type: :controller do

  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'POST create' do

    let(:attributes) { attributes_for(:user)}

    context 'with SIGN_UP_NOTIFICATION_RECIPIENTS env provided' do
      before do
        ENV['SIGN_UP_NOTIFICATION_RECIPIENTS'] = 'hans.muster@test.com, peter.meier@test.com'
      end

      it 'sends notification mail' do
        expect { post :create, params: {user: attributes} }.to change(ActionMailer::Base.deliveries, :count).by 1
      end
    end

    context 'with empty SIGN_UP_NOTIFICATION_RECIPIENTS env provided' do
      before do
        ENV['SIGN_UP_NOTIFICATION_RECIPIENTS'] = ''
      end

      it 'sends no notification mail' do
        expect { post :create, params: {user: attributes} }.to change(ActionMailer::Base.deliveries, :count).by 0
      end
    end

    context 'without SIGN_UP_NOTIFICATION_RECIPIENTS env provided' do

      it 'sends no notification mail' do
        expect { post :create, params: {user: attributes} }.to change(ActionMailer::Base.deliveries, :count).by 0
      end
    end

  end
end
