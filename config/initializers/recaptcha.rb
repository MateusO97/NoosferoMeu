Recaptcha.configure do |config|
  config.site_key   = NOOSFERO_CONF['api_recaptcha_site_key'] || '6LfFpV4UAAAAALq_kGj5vfQq9trhnPpYUvphvdZP'
  config.secret_key = NOOSFERO_CONF['api_recaptcha_private_key'] || '6LfFpV4UAAAAAGTHhIwmGOnnIAIu43B_RdjUpcLx'
end
