# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
['Kl. Saal', 'Gr. Saal', 'Hr. WC', 'Büro'].each do |sensor|
  time = DateTime.now - 2.weeks
  v = 2000 # Startwert 20° 
  while (time < DateTime.now) do
    # Temperature per "Random Walk" erstellen.
    v = [900, [3500, v + 200 * (rand - 0.5)].min].max.floor

    Measurement.create(sensor: sensor, value: v, created_at: time)
    time += 1.minutes
  end
end
