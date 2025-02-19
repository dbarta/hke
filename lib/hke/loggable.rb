# hke/lib/hke/loggable.rb
require_relative 'log_helper'

module Hke
  module Loggable
    extend ActiveSupport::Concern

    def init_logging(filename)
      Hke::LogHelper.instance.init_logging(filename)
    end

    def log_info(msg)
      Hke::LogHelper.instance.log_info(msg)
    end

    def log_error(msg)
      Hke::LogHelper.instance.log_error(msg)
    end

  end
end
