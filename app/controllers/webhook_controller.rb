class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'aws-sdk'
def current_date
  date = Time.now
  #現在から10分前の日時を取得する。
  date = date - 60*10
  return date
end

def get_s3_image
  bucket = Aws::S3::Resource.new(
                              :region => 'ap-northeast-1',
                              :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
                              :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
                              ).bucket('sayang-images')

  bucket.objects.each do |obj|
    if obj.last_modified >= current_date
       obj.last_modified
       url = "https://s3-ap-northeast-1.amazonaws.com/sayang-image/#{obj.key}"
    end
  end
  return url
end

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token  = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type:               'image',
	    originalContentUrl: get_s3_image,
	    previewImageUrl:    get_s3_image
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
