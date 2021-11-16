class LineBotController < ApplicationController
  # 指定したアクションではprotect_from_forgeryを実行しなくなる
  protect_from_forgery expect: [:callback]

  def callback
  end
end
