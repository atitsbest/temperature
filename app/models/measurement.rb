class Measurement < ActiveRecord::Base
  validates_presence_of :sensor, :value, :created_at
end
