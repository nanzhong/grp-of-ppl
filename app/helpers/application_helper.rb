module ApplicationHelper
  def publish(channel, event, data = {}, &block)
    PubSub.publish(channel, event, data.merge(:html => capture(&block)))
  end

end
