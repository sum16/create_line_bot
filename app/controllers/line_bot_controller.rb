class LineBotController < ApplicationController
  # 指定したアクションではprotect_from_forgeryを実行しなくなる
  protect_from_forgery expect: [:callback]

  def callback
  end

  private

  def client
    @client || Line::Bot::Client.new { |config|
      config.LINE_CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
      config.LINE_CHANNEL_TOKEN = ENV['LINE_CHANNEL_TOKEN']
    }
  end
end


# ||=は左辺がnilやfalseの場合、右辺を代入するという意味
# 2回目にclientメソッドが呼び出されたときは、@clientにはすでにインスタンスが入っているため、右辺のコードは実行されない

# Line::Bot::Clientクラスのインスタンス化ですが、引数をブロック({})で与える必要があります。これはLine::Bot::Clientクラスの仕様によるもの
