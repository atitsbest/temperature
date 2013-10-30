# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
['Kl. Saal', 'Gr. Saal', 'Hr. WC', 'Büro'].each do |sensor|
  time = DateTime.now - 1.month
  while (time < DateTime.now) do
    Measurement.create(sensor: sensor, value: rand(9000..35000), created_at: time)
    time += 10.minutes
  end
end
