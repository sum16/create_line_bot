class LineBotController < ApplicationController
  # 指定したアクションではprotect_from_forgeryを実行しなくなる
  protect_from_forgery expect: [:callback]

  def callback
    #1 
    body = request.body.read
    #2
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end
    # events以下の要素を配列で取得 #３の形に変換
    events = client.parse_events_from(body)
    # p "イベント：　#{events}"
    events.each do |event|
      case event
        # Line::Bot::Event::Messageクラスかどうか判定/メッセージイベントであった場合、次のcase文が実行
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text'] # テキストを取得
          }
          # p message
          # 第一引数に応答トークン、第二引数に先程宣言したmessageを渡すと、メッセージの返信がおこなわれる
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end


# ||=は左辺がnilやfalseの場合、右辺を代入するという意味
# 2回目にclientメソッドが呼び出されたときは、@clientにはすでにインスタンスが入っているため、右辺のコードは実行されない

# Line::Bot::Clientクラスのインスタンス化ですが、引数をブロック({})で与える必要があります。これはLine::Bot::Clientクラスの仕様によるもの


#1 LINEプラットフォームからのPOSTリクエストには署名の情報が含まれており、これを検証することで本物のLINEプラットフォームから送信されたリクエストであることを確認することができる
#  署名の情報はヘッダーに含まれるため、今回はヘッダーを参照する必要がある/request.envとすることでヘッダーだけを参照することができる 
#  署名はHTTP_X_LINE_SIGNATUREに格納されている

#2 clientメソッドにアクセスすることでLine::Bot::Clientクラスをインスタンス化している
#  Line::Bot::Clientクラスのvalidate_signatureメソッドは、メッセージボディと署名を引数として受け取り、署名の検証をおこなう → trueかfalsで返却

# headメソッドはステータスコードを返したいときに使用 :bad_requestを指定すると400が返されます。


#3 
# [
#   {
#     "type"=>"message",
#     "replyToken"=>"xxxxx",
#     "source"=>
#     {
#       "userId"=>"xxxxx",
#       "type"=>"user"
#     },
#     "timestamp"=>1604318772845,
#     "mode"=>"active",
#     "message"=>
#     {
#       type"=>"text",
#       "id"=>"xxxxx",
#       "text"=>"こんにちは"
#     }
#   }
# ]
