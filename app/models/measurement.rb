class Measurement < ActiveRecord::Base
  validates_presence_of :sensor, :value, :created_at

  # Liefert alle Sensor-Namen die in allen Messungen vorkommen.
  def self.sensor_names
    self.select(:sensor).distinct.map {|s| s.sensor}
  end

  # Liefert die aktuelle/letzte Temperatur für einen Sensor
  def self.current_temperature_for sensor_name
    self.select(:value)
        .where(:sensor => sensor_name)
        .order(:created_at)
        .last.value
  end
end
