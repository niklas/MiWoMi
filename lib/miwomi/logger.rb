require 'active_support/logger'
require 'active_support/benchmarkable'
module Miwomi
  module Logger
    include ActiveSupport::Benchmarkable
    LOGGER = ActiveSupport::Logger.new('miwomi.log')
    def logger
      LOGGER
    end
  end
end
