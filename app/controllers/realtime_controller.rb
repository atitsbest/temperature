class RealtimeController < ApplicationController
  include ActionController::Live

  skip_before_action :verify_authenticity_token
  
  def measurements
    setup_stream

    begin
      redis = Redis.new
      redis.subscribe('temperature_update') do |on|
        on.message do |event, data|
          @stream.write(data, :event => :update)
        end
      end
    ensure
      @stream.close
    end

  end

  private

    def setup_stream
      response.headers['Content-Type'] = 'text/event-stream'
      @stream = Sse::Writer.new(response.stream)
    end
    
end

