module ApplicationHelper

  def publish(channel, event, data = {}, &block)
    Push.publish(channel, event, data.merge(:html => capture(&block)))
  end

end
