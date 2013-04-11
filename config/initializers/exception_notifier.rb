Rails.application.config.middleware.use ExceptionNotifier,
  :email_prefix => "ViewFinder Error:",
  :sender_address => %{"notifier" <postmaster@viewfinder.mailgun.org>},
  :exception_recipients => %w{eugene.wang@flatironschool.com}