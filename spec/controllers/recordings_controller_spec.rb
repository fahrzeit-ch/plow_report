require 'rails_helper'

RSpec.describe RecordingsController, type: :controller do

  let(:current_user) { create(:user) }
  let(:current_driver) { current_user.drivers.last }

  before { sign_in current_user }

  describe 'POST #create' do
    subject { current_driver }
    before { post :create }

    it { is_expected.to be_recording }

  end

  describe 'DELETE #destroy' do
    subject { current_driver }

    before do
      current_driver.start_recording
      delete :destroy
      current_driver.reload
    end

    it { is_expected.not_to be_recording }
  end

  describe 'PUT #finish' do
    before do
      current_driver.start_recording
    end

    it 'should finish recording' do
      put :finish, params: { drive: attributes_for(:drive) }
      current_driver.reload
      expect(current_driver).not_to be_recording
    end
  end


end