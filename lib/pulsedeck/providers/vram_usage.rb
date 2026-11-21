# typed: strict
# frozen_string_literal: true

module Pulsedeck
  module Providers
    # AMD GPU video memory in use, from the amdgpu driver.
    class VramUsage < Base
      sig { override.returns(String) }
      def id = 'vram_usage'

      sig { override.returns(String) }
      def label = 'VRAM usage'

      sig { override.returns(String) }
      def unit = 'GB'

      sig { override.returns(T.nilable(Float)) }
      def read
        bytes = Hwmon.read_integer(driver: 'amdgpu', file: 'device/mem_info_vram_used')
        bytes && (bytes / (1024.0**3))
      end
    end
  end
end
