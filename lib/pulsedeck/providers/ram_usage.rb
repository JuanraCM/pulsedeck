# typed: strict
# frozen_string_literal: true

module Pulsedeck
  module Providers
    # Used RAM in GB (MemTotal minus MemAvailable), from /proc/meminfo.
    class RamUsage < Base
      MEMINFO = '/proc/meminfo'

      sig { override.returns(String) }
      def id = 'ram_usage'

      sig { override.returns(String) }
      def label = 'RAM usage'

      sig { override.returns(String) }
      def unit = 'GB'

      sig { override.returns(T.nilable(Float)) }
      def read
        text = File.read(MEMINFO)
        total = field(text, 'MemTotal')
        available = field(text, 'MemAvailable')
        return nil unless total && available

        (total - available) / (1024.0 * 1024)
      rescue SystemCallError
        nil
      end

      private

      sig { params(text: String, name: String).returns(T.nilable(Integer)) }
      def field(text, name)
        match = text.match(/^#{name}:\s+(\d+)\s*kB/)
        match && Integer(match[1], 10)
      end
    end
  end
end
