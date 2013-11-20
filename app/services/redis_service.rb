class RedisService

  def self.entry(date, value)
    "{\"d\":#{date},\"v\":#{value}}"
  end

  def self.key(sensor)
    "#{sensor}:all"
  end

  def self.score(date)
    date.to_i
  end

end

