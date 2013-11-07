class Api::MeasurementsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  # Alle Measurements ermitteln.
  def index
    ms = Measurement.order(:created_at)
      # .where("created_at > ?", DateTime.now - 3.days) 
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
