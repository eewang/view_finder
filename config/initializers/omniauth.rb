Rails.application.config.middleware.use OmniAuth::Builder do
  provider :instagram, ENV['INSTAGRAM_APP_ID'], ENV['INSTAGRAM_SECRET']
end

Instagram.configure do |config|
  config.client_id = ENV['INSTAGRAM_APP_ID']
  config.client_secret = ENV['INSTAGRAM_SECRET']
end