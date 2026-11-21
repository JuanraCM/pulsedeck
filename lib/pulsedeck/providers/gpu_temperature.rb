# typed: strict
# frozen_string_literal: true

module Pulsedeck
  module Providers
    # AMD GPU temperature from the amdgpu driver.
    class GpuTemperature < Base
      sig { override.returns(String) }
      def id = 'gpu_temperature'

      sig { override.returns(String) }
      def label = 'GPU temperature'

      sig { override.returns(String) }
      def unit = '°C'

      sig { override.returns(T.nilable(Float)) }
      def read
        millidegrees = Hwmon.read_integer(driver: 'amdgpu', file: 'temp1_input')
        millidegrees && (millidegrees / 1000.0)
      end
    end
  end
end
