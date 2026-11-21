# typed: strict
# frozen_string_literal: true

module Pulsedeck
  module Providers
    # AMD GPU load from the amdgpu driver.
    class GpuLoad < Base
      sig { override.returns(String) }
      def id = 'gpu_load'

      sig { override.returns(String) }
      def label = 'GPU load'

      sig { override.returns(String) }
      def unit = '%'

      sig { override.returns(T.nilable(Float)) }
      def read
        percent = Hwmon.read_integer(driver: 'amdgpu', file: 'device/gpu_busy_percent')
        percent&.to_f
      end
    end
  end
end
