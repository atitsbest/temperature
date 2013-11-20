# Temperatur-Daten aus der DB downsamplen und in Redis
# zwischenspeichern.
class DownsampleWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly(3) }

  MAX_MEASUREMENTS = 500

  def perform
    # Redis Client erzeugen.
    redis = Redis.new

    # Sensoren ermitteln.
    sensors = Measurement.sensor_names

    # Pro Sensor
    sensors.each do |sensor|
      # Rails.logger.debug "Found sensor #{sensor}."
      # Redis-Temp-Key-Name erstellen.
      redis_key = RedisService.key sensor
      redis_temp_key = "#{redis_key}:#{DateTime.now.to_i}"
      # Rails.logger.debug "Redis temp key is #{redis_temp_key}"

      # Anzahl Messungen ermitteln.
      count = Measurement.where(:sensor => sensor).count()
      # Rails.logger.debug "Found #{count} measurements for sensor #{sensor}."
    
      # Chunk-Größe ermitteln
      chunk_size = (count / MAX_MEASUREMENTS).ceil
      # Rails.logger.debug "Chunk size: #{chunk_size}."
    
      # Aktueller Offset, wird pro Durchlauf um chunck_size erhöht.
      offset = 0

      # Pro Chunk
      while(offset <= count) 

        # AVG(temp), AVG(date)
        chunks = Measurement.find_by_sql("SELECT * FROM measurements
                                         WHERE sensor = '#{sensor}'
                                         LIMIT #{chunk_size}
                                         OFFSET #{offset}");
        offset += chunk_size
        
        # Eintrag erstellen
        avg_value = chunks.inject(0) { |sum, c| sum + c.value.to_i } / chunks.size
        avg_date = chunks.inject(0) { |sum, c| sum + c.created_at.to_i } / chunks.size
        entry = RedisService.entry avg_date, avg_value
        
        # In Redis speichern
        # Rails.logger.debug "Add #{entry} to redis"
        redis.zadd(redis_temp_key, avg_date, entry)
      end
      
      # Letzten Eintrag immer mitnehmen.
      last = Measurement.where(:sensor => sensor).order(:created_at).last
      redis.zadd(redis_temp_key, 
                 RedisService.score(last.created_at), 
                 RedisService.entry(last.created_at, last.value))

      # Rails.logger.debug "Temporary set for sensor #{sensor} finished."
    
      redis.multi do
        # Altes Redis-Set löschen 
        # Rails.logger.debug "Remove old key"
        redis.del(redis_key) if redis.exists(redis_key)
        # Neues auf Namen von altem umbenennen
        # Rails.logger.debug "Rename temporary key"
        redis.rename(redis_temp_key, redis_key)
      end
      # Rails.logger.debug "Temporary set renamed."
    end

  end
end
