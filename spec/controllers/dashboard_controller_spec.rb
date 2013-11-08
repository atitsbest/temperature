require 'spec_helper'

describe DashboardController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'

      response.should be_success
    end

    it "assigns viewmodel" do
      get 'index'

      model = assigns :model
      expect(model).not_to be nil
    end

    it "should contain current temperature of all sensors" do
      get 'index'

      model = assigns :model
      expect(model.sensors.length).to eq 2
      [13.50, 31.13].should include model.sensors[1].current_temperature
      [13.50, 31.13].should include model.sensors[0].current_temperature
    end
  end

end
