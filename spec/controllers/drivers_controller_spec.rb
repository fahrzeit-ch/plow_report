require 'rails_helper'

RSpec.describe DriversController, type: :controller do

  let(:user) { create(:user, skip_create_driver: true) }
  before { sign_in user }

  describe 'POST create' do
    it 'should create a default driver' do
      expect {
        post :create
      }.to change(Driver, :count).by(1)
    end

    it 'should redirect to dashboard' do
      expect(post(:create)).to redirect_to(root_path)
    end

    context 'with existing personal driver' do
      before { user.drivers.create(name: user.name) }

      it 'should redirect to root' do
        expect(post(:create)).to redirect_to(root_path)
      end

      it 'should not create a new drier' do
        expect{
          post :create
        }.not_to change(Driver, :count)
      end
    end

  end

end