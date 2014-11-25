#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'timeout'
require 'redis'
require 'multi_json'

class Yammer < Sensu::Handler
  def handle
    og_url       = settings['yammer']['og_url'] || 'http://localhost:8080/'
    og_title     = settings['yammer']['og_title'] || 'Sensu'
    og_image     = settings['yammer']['og_image'] || 'http://sensuapp.org/img/sensu_logo_large-c92d73db.png'
    access_token = settings['yammer']['access_token']
    group_id     = settings['yammer']['group_id']

    begin
      redis = ::Redis.new(symbolize_keys(settings['redis']))

      key = ['sensu-yammer-handler', @event['client']['name'], @event['check']['name']].join(':')

      message_id = redis.get(key)

      message_id = post_to_yammer(og_url, og_title, og_image, access_token, group_id, message_id)

      resolve? ? redis.del(key) : redis.set(key, message_id)
    ensure
      redis.quit if redis
    end
  end

  private

  def symbolize_keys(hash)
    ::MultiJson.load(::MultiJson.dump(hash.dup), :symbolize_keys => true)
  end

  def post_to_yammer(og_url, og_title, og_image, access_token, group_id, replied_to_id)
    message_id = nil
    begin
      timeout 10 do
        https = Net::HTTP.new("www.yammer.com", 443)
        https.use_ssl = true
        res = https.start do |conn|
          conn.post("/api/v1/messages.json", URI.encode_www_form({
            :group_id => group_id,
            :og_url => og_url,
            :og_title => og_title,
            :og_image => og_image,
            :replied_to_id => replied_to_id,
            :body => make_body
          }), {'Authorization' => "Bearer #{access_token}"})
        end

        if res.is_a? Net::HTTPSuccess
          messages = ::MultiJson.load(res.body)['messages']
          message_id = messages[0]['id']
        end

        puts 'yammer -- sent alert for ' + short_name + ' to ' + group_id
      end
    rescue Timeout::Error
      puts 'yammer -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name
    end
    message_id
  end

  def make_body
    playbook = "Playbook:  #{@event['check']['playbook']}" if @event['check']['playbook']
    body = <<-BODY.gsub(/^\s+/, '')
            #{action_to_string} - #{short_name}: #{status_to_string}

            Host: #{@event['client']['name']} ( #{@event['client']['address']} )
            Check:  #{@event['check']['name']}
            Status:  #{status_to_string}
            Occurrences:  #{@event['occurrences']}
            #{playbook}
            #{@event['check']['output']}
          BODY
    body
  end

  def short_name
    @event['client']['name'] + ' / ' + @event['check']['name']
  end

  def resolve?
    @event['action'].eql?('resolve')
  end

  def action_to_string
    resolve? ? "[RESOLVED]" : "[ALERT]"
  end

  def status_to_string
    case @event['check']['status']
    when 0
      'OK'
    when 1
      'WARNING'
    when 2
      'CRITICAL'
    else
      'UNKNOWN'
    end
  end

end
