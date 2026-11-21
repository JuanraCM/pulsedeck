# typed: strict
# frozen_string_literal: true

module Pulsedeck
  # Position and size of a widget in the dashboard grid, in cells. Column and row start at 1.
  class Placement < T::Struct
    extend T::Sig

    const :column, Integer
    const :row, Integer
    const :width, Integer, default: 1
    const :height, Integer, default: 1

    sig { params(column: Integer, row: Integer, width: Integer, height: Integer).void }
    def initialize(column:, row:, width: 1, height: 1)
      super
      invalid = { column: column, row: row, width: width, height: height }.select { |_, value| value < 1 }
      raise ArgumentError, "Placement values must be 1 or more: #{invalid.keys.join(', ')}" unless invalid.empty?
    end
  end
end
