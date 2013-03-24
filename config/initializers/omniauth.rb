Rails.application.config.middleware.use OmniAuth::Builder do
  use OmniAuth::Strategies::Instagram, ENV['INSTAGRAM_APP_ID'], ENV['INSTAGRAM_SECRET']
end

# OmniAuth.config.on_failure = UsersController.action(:oauth_failure)