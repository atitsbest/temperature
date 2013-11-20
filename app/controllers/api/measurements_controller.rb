class Api::MeasurementsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  # Alle Measurements ermitteln.
  def index
    redis = Redis.new

    result = Measurement.sensor_names.map do |sensor|
      "\"#{sensor}\": [" << redis.zrange("#{sensor}:all", 0, -1).join(',') << "]"
    end

    render json: "{#{result.join(',')}}"
  end

  # Measurement erstellen.
  def create
    # Datenbank-Eintrag erstellen.
    mm = Measurement.create!(safe_params) do |m|
      m.created_at = DateTime.now
    end

    # Neuen Wert in Redis speichern.
    redis = Redis.new
    key = RedisService.key mm.sensor
    entry = RedisService.entry mm.created_at, mm.value
    score = RedisService.score mm.created_at

    redis.zadd key, score, entry
    redis.publish('temperature_update', "{\"sensor\": \"#{mm.sensor}\", \"data\": #{entry}}")

    render text: '', status: 201
  end

  private

    def safe_params
      params.require(:measurement).permit(:sensor, :value)
    end
    
end
