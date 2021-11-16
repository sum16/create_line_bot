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
