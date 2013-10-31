class Api::MeasurementsController < ApplicationController
  
  # Alle Measurements ermitteln.
  def index
    ms = Measurement.order(:created_at)
    render json: ms
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
