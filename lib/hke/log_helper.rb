require "logger"

module Hke
  module LogHelper

    def log(filename)
      timestamp = Time.now.strftime("%H%M%S") # 143000
      # log_path = Rails.root.join("log", "#{filename}_#{timestamp}.log")
      log_path = Rails.root.join("log", "#{filename}.log")
      logger = Logger.new(log_path)
      logger.datetime_format = "%Y-%m-%d %H:%M"
      logger
    end

    def init_logging(filename)
      @debug = Rails.env.development?
      @info = log("info_" + filename)
      @error = log("error_" + filename)
      @num_errors = 0
    end

    def log_info(msg)
      puts "@@@ INFO: #{msg}" if @debug
      @info.info(msg)  # Corrected method call
    end

    def log_error(msg)
      puts "@@@ ERROR: #{msg}" if @debug
      @error.error(msg)  # Corrected method call
      @num_errors += 1
    end
  end
end
