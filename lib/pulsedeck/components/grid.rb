# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Grid < Phlex::HTML
      extend T::Sig

      sig { params(columns: Integer, rows: Integer).void }
      def initialize(columns:, rows:)
        @columns = columns
        @rows = rows
        super()
      end

      sig { params(block: T.proc.void).void }
      def view_template(&block)
        tracks = "grid-template-columns: repeat(#{@columns}, 1fr); grid-template-rows: repeat(#{@rows}, 1fr);"
        div(class: 'grid', style: tracks, &block)
      end
    end
  end
end
