class Api::MeasurementsController < ApplicationController
  
  # Alle Measurements ermitteln.
  def index
    ms = Measurement.order(:created_at)
    respond_to do |f|
      f.json { render json: ms.to_a }
      f.csv { render text: ms.to_csv }
    end
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
