class DashboardIndex
  class Sensor
    attr_accessor :name, 
                  :current_temperature

    # CTR
    def initialize name
      @name = name
    end
  end
  
  attr_accessor :sensors
end
