require 'spec_helper'

describe 'Measurement' do
  it 'should list all sensor names' do
    Measurement.sensor_names.should =~ ['Gr. Saal', 'Kl. Saal']
  end

  it 'should get current temperature for sensor' do
    expect(Measurement.current_temperature_for 'Gr. Saal').to be 1350
  end

  it 'should get time of last update for sensor' do
    expect((Measurement.last_update_for 'Kl. Saal').to_i).to be DateTime.parse('2013-10-29 13:11:33').to_i
  end
end
