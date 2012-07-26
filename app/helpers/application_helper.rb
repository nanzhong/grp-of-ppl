module ApplicationHelper

  def publish(channel, event, &block)
    Push.publish(channel, event, capture(&block))
  end

end
