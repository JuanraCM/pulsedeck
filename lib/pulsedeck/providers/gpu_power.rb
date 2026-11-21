# typed: strict
# frozen_string_literal: true

module Pulsedeck
  module Providers
    # AMD GPU power from the amdgpu driver.
    class GpuPower < Base
      sig { override.returns(String) }
      def id = 'gpu_power'

      sig { override.returns(String) }
      def label = 'GPU power'

      sig { override.returns(String) }
      def unit = 'W'

      sig { override.returns(T.nilable(Float)) }
      def read
        microwatts = Hwmon.read_integer(driver: 'amdgpu', file: 'power1_average') ||
                     Hwmon.read_integer(driver: 'amdgpu', file: 'power1_input')
        microwatts && (microwatts / 1_000_000.0)
      end
    end
  end
end
