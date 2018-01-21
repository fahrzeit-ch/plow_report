require "rails_helper"

RSpec.describe DrivesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/drives").to route_to("drives#index")
    end

    it "routes to #new" do
      expect(:get => "/drives/new").to route_to("drives#new")
    end

    it "routes to #show" do
      expect(:get => "/drives/1").to route_to("drives#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/drives/1/edit").to route_to("drives#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/drives").to route_to("drives#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/drives/1").to route_to("drives#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/drives/1").to route_to("drives#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/drives/1").to route_to("drives#destroy", :id => "1")
    end

  end
end
