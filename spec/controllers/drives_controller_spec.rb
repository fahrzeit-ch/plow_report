# frozen_string_literal: true

require "rails_helper"

RSpec.describe DrivesController, type: :controller do
  let(:user) { create(:user) }
  before { user.create_personal_driver }

  describe "GET #index" do
    subject { response }

    context "signed out" do
      it "should redirect to login" do
        get :index
        expect(subject).to redirect_to "/users/sign_in"
      end
    end

    context "signed in" do
      before { sign_in user }

      it "should be successful" do
        get :index
        expect(subject).to be_success
      end
    end
  end

  describe "GET #suggested_km" do
    subject { response }
    context "signed in" do
      before do
        sign_in user
        create(:drive, driver: user.drivers.first)
      end

      context "no similar drives" do
        it "be successful" do
          get :suggested_values, params: { format: :json }
          expect(subject).to be_success
        end
      end
    end
  end

  describe "POST #create" do
    let(:activity) { create(:value_activity) }
    let(:valid_params) { attributes_for(:drive).merge({ activity_execution_attributes: { activity_id: activity.id, value: 10 } }) }

    context "signed out" do
      it "should redirect to login" do
        post :create, params: valid_params
        expect(subject).to redirect_to "/users/sign_in"
      end
    end

    context "signed in" do
      before { sign_in user }

      context "with valid attributes" do
        it "should redirect to index page" do
          post :create, params: { drive: valid_params }
          expect(subject.status).to redirect_to "/drives"
        end

        it "should create drive with the users driver" do
          expect {
            post :create, params: { drive: valid_params }
          }.to change(Drive.where(driver: user.drivers.last), :count)
        end

        it "stores the activity" do
          post :create, params: { drive: valid_params }
          expect(Drive.last.activity_execution.value).to eq(10)
        end
      end
    end
  end
end
