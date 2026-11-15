# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Panel < Phlex::HTML
      extend T::Sig

      STYLE = 'border: 1px solid #444; border-radius: 8px; padding: 1rem; min-width: 12rem;'
      TITLE_STYLE = 'margin: 0 0 0.5rem; font-size: 1rem;'

      sig { params(title: String).void }
      def initialize(title:)
        @title = title
        super()
      end

      sig { params(block: T.proc.void).void }
      def view_template(&block)
        section(class: 'panel', style: STYLE) do
          h2(style: TITLE_STYLE) { @title }
          div(class: 'panel-body', &block)
        end
      end
    end
  end
end
