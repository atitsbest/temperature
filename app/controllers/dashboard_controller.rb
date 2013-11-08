class DashboardController < ApplicationController
  def index
    @model = DashboardIndex.new
    @model.sensors = Measurement.sensor_names.map do |name|
      sensor = DashboardIndex::Sensor.new name
      sensor.current_temperature = (Measurement.current_temperature_for name) / 100.0
      # sensor.average_temperature = Measurement.average_temperature_for name
      sensor
    end
  end
end
