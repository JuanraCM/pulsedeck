# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Panel < Phlex::HTML
      extend T::Sig

      sig { params(title: String, placement: Placement).void }
      def initialize(title:, placement:)
        @title = title
        @placement = placement
        super()
      end

      sig { params(block: T.proc.void).void }
      def view_template(&block)
        section(class: 'panel', style: style) do
          h2(class: 'panel-title') { @title }
          div(class: 'panel-body', &block)
        end
      end

      private

      sig { returns(String) }
      def style
        p = @placement
        "grid-column: #{p.column} / span #{p.width}; grid-row: #{p.row} / span #{p.height}"
      end
    end
  end
end
