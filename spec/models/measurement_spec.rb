require 'spec_helper'

describe 'Measurement' do
  it 'should list all sensor names' do
    Measurement.sensor_names.should =~ ['Gr. Saal', 'Kl. Saal']
  end

  it 'should get current temperature for sensor' do
    expect(Measurement.current_temperature_for 'Gr. Saal').to be 13500
  end
end
