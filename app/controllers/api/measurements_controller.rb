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
    Measurement.create!(safe_params) do |m|
      m.created_at = DateTime.now
    end
    render text: '', status: 201
  end

  private

    def safe_params
      params.require(:measurement).permit(:sensor, :value)
    end
end
