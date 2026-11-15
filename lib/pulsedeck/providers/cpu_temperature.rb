# typed: strict
# frozen_string_literal: true

module Pulsedeck
  module Providers
    # AMD CPU temperature from the k10temp driver.
    class CpuTemperature < Base
      sig { override.returns(String) }
      def label = 'CPU temperature'

      sig { override.returns(String) }
      def unit = '°C'

      sig { override.returns(T.nilable(Float)) }
      def read
        millidegrees = Hwmon.read_integer(driver: 'k10temp', file: 'temp1_input')
        millidegrees && (millidegrees / 1000.0)
      end
    end
  end
end
