require "rails_helper"

RSpec.describe StandbyDatesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/standby_dates").to route_to("standby_dates#index")
    end

    it "routes to #new" do
      expect(:get => "/standby_dates/new").to route_to("standby_dates#new")
    end

    it "routes to #show" do
      expect(:get => "/standby_dates/1").to route_to("standby_dates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/standby_dates/1/edit").to route_to("standby_dates#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/standby_dates").to route_to("standby_dates#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/standby_dates/1").to route_to("standby_dates#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/standby_dates/1").to route_to("standby_dates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/standby_dates/1").to route_to("standby_dates#destroy", :id => "1")
    end

  end
end
