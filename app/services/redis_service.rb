class RedisService

  def self.entry(date, value)
    "{\"d\":#{date.to_i},\"v\":#{value}}"
  end

  def self.key(sensor)
    "#{sensor}:all"
  end

  def self.score(date)
    date.to_i
  end

end

