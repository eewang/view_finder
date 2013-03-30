Rails.application.config.middleware.use OmniAuth::Builder do
  provider :instagram, ENV['INSTAGRAM_APP_ID'], ENV['INSTAGRAM_SECRET']

# Instagram.configure do |config|
#   config.client_id = "9fd83d36f6094ef59fbaaadd8febab43"
#   config.access_token = "305166995.9fd83d3.347d159cd5a94d638d7fc1df970c88b4"
# end

# OmniAuth.config.on_failure = UsersController.action(:oauth_failure)