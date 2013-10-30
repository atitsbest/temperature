class MeasurementSerializer < ActiveModel::Serializer
  attributes :sensor, :value, :created_at
end
