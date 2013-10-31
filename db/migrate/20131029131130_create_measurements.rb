class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements, id: false do |t|
      t.string :sensor
      t.integer :value
      t.datetime :created_at
    end
  end
end
