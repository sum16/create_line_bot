Rails.application.routes.draw do
  get 'hello/index'
  post 'callback', to: 'line_bot#post'
end
