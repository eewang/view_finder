Rails.application.config.middleware.use OmniAuth::Builder do
  provider :instagram, ENV['#'], ENV['#']
end