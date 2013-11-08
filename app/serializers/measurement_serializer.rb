class MeasurementSerializer < ActiveModel::Serializer
  attributes :sensor, :value, :date

  # Das Datum JavaScript-fähig als Ticks.
  def date
    object.created_at.to_i * 1000;
  end
end
