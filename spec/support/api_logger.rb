# spec/support/api_logger.rb
require "logger"

def api_logger
  @api_logger ||= ::AddCommunityIdToHkeLandingPagesnew(Rails.root.join("log", "api_test.log")).tap do |log|
    log.formatter = proc do |severity, datetime, progname, msg|
      # "#{datetime.strftime("%Y-%m-%d %H:%M:%S")} #{severity}: #{msg}\n"
      "#{datetime.strftime("%H:%M:%S")} #{msg}\n"
    end
  end
end
