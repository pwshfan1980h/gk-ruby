class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "gk-ruby@localhost")
  layout "mailer"
end
