module Push

  def self.publish(channel, event, data)
    Pusher[channel].trigger(event, data)
  end

end
