class Api::MeasurementsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
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

  # Dataset decimated
  def chunked
    ms = Measurement.order(:created_at)
    result = []

    count = (params[:count] || '10').to_i
  
    # Nach Sensor gruppieren
    ms.group_by {|m| m.sensor}.each do |key, value|

      # in chunks unterteilen
      chunked = value.each_slice(count).to_a
      # Durchschnitt ermitteln.
      chunked.map do |c|
        value = c.inject(0.0) { |sum, el| sum + el.value } / c.size
        created_at = c.last.created_at
        result << Measurement.new({sensor: key, value: value, created_at: created_at})
      end

    end
    
    render json: result
  end

  private

    def safe_params
      params.require(:measurement).permit(:sensor, :value)
    end
end
