Rails.application.config.middleware.use OmniAuth::Builder do
  provider :instagram, "d3e6c95d842c4e91b659b4037769d729", "95a936548ff54b6ab2a28bda596841ee"
end

# Instagram.configure do |config|
#   config.client_id = "9fd83d36f6094ef59fbaaadd8febab43"
#   config.access_token = "305166995.9fd83d3.347d159cd5a94d638d7fc1df970c88b4"
# end

# OmniAuth.config.on_failure = UsersController.action(:oauth_failure)