#!/usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'timeout'

class Yammer < Sensu::Handler
  def handle
    og_url       = settings['yammer']['og_url'] || 'http://localhost:8080/'
    og_title     = settings['yammer']['og_title'] || 'Sensu'
    og_image     = settings['yammer']['og_image'] || 'http://sensuapp.org/img/sensu_logo_large-c92d73db.png'
    access_token = settings['yammer']['access_token']
    group_id     = settings['yammer']['group_id']

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


    begin
      timeout 10 do
        https = Net::HTTP.new("www.yammer.com", 443)
        https.use_ssl = true
        https.start do |conn|
          conn.post("/api/v1/messages.json", URI.encode_www_form({
            :group_id => group_id,
            :og_url => og_url,
            :og_title => og_title,
            :og_image => og_image,
            :body => body
          }), {'Authorization' => "Bearer #{access_token}"})
        end

        puts 'yammer -- sent alert for ' + short_name + ' to ' + group_id
      end
    rescue Timeout::Error
      puts 'yammer -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name
    end
  end

  private
  def short_name
    @event['client']['name'] + ' / ' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? "[RESOLVED]" : "[ALERT]"
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
