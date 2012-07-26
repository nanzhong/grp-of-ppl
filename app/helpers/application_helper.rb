require 'net/http'

module ApplicationHelper

  def publish(channel, &block)
    message = { :channel => channel, :data => capture(&block) }
    uri = URI.parse("http://nan.enflick.com:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

end
