require 'spec_helper'

describe Api::MeasurementsController do
  fixtures :measurements

  describe 'index' do

    it "should return all measurements for all sensors in json" do
      get api_measurements_path, format: :json
      response.should be_success
    end

    it "should return all measurements for all sensors in csv" do
      get api_measurements_path, format: :csv
      response.should be_success

      csv = CSV.parse response.body
      csv.should_not be_nil
      csv.should have(3).things
    end

  end


  describe 'create' do
    it 'should add new measurement to db' do
   
      expect {
        post(api_measurements_path,
          measurement: { sensor: 'Kl. Saal', value: '22000' }, 
          format: :json)
      }.to change(Measurement, :count).by(1)

      response.should be_success
    end
  end
end
