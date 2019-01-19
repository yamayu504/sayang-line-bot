class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def client
    @client = Line::Bot::Client.new { |config|
      config.channel_secret = "085c6531912a544ac62338c8c5a88285"
      config.channel_token  = "qWSAno3Y+jZmXKyRWJsTxiuX1JNonuGoCgBRbFnpC1YZxrvrnN5IXOzA1pgpBEMSzvvst7bRFeWVSGdSOMiKlVG+klvr2NeGpi2Kbxi6NbCH5fYURcWh6xQuWjrruffQ5wBQTq/kFR079axxRzhPewdB04t89/1O/w1cDnyilFU="
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
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }

    head :ok
  end
end
