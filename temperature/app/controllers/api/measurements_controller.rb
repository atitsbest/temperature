class Api::MeasurementsController < ApplicationController
  def index
    @ms = Measurement.order(:created_at)
    respond_to do |f|
      f.json { render json: @ms }
      f.csv { render text: @ms.to_csv }
    end
  end
end
