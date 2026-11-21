# typed: strict
# frozen_string_literal: true

module Pulsedeck
  module Providers
    # CPU load in percent, from the change of the /proc/stat counters between two reads.
    class CpuLoad < Base
      STAT = '/proc/stat'

      sig { void }
      def initialize
        super
        @previous = T.let([0, 0], [Integer, Integer])
      end

      sig { override.returns(String) }
      def id = 'cpu_load'

      sig { override.returns(String) }
      def label = 'CPU load'

      sig { override.returns(String) }
      def unit = '%'

      sig { override.returns(T.nilable(Float)) }
      def read
        sample = sample_counters
        return nil unless sample

        idle_delta = sample[0] - @previous[0]
        total_delta = sample[1] - @previous[1]
        @previous = sample
        return nil if total_delta.zero?

        100.0 * (1 - (idle_delta.to_f / total_delta))
      end

      private

      # Returns [idle, total] from the first "cpu" line, or nil.
      sig { returns(T.nilable([Integer, Integer])) }
      def sample_counters
        line = File.foreach(STAT).first
        return nil unless line&.start_with?('cpu ')

        counters(line.split.drop(1).map { |field| Integer(field, exception: false) })
      rescue SystemCallError
        nil
      end

      sig { params(fields: T::Array[T.nilable(Integer)]).returns(T.nilable([Integer, Integer])) }
      def counters(fields)
        numbers = fields.compact
        return nil if numbers.size != fields.size

        user, nice, system, idle, iowait = numbers
        return nil unless user && nice && system && idle && iowait

        [idle + iowait, numbers.sum]
      end
    end
  end
end
