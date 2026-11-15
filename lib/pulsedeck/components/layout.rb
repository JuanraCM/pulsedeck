# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Layout < Phlex::HTML
      extend T::Sig

      CSS = <<~CSS
        body { margin: 0; padding: 1rem; background: #111; color: #eee; font-family: sans-serif; }
        h1 { margin-top: 0; }
        .panels { display: flex; gap: 1rem; flex-wrap: wrap; }
      CSS

      sig { params(block: T.proc.void).void }
      def view_template(&block)
        doctype
        html do
          head do
            meta(charset: 'utf-8')
            meta(name: 'viewport', content: 'width=device-width, initial-scale=1')
            title { 'Pulsedeck' }
            style { raw safe(CSS) }
          end
          body(&block)
        end
      end
    end
  end
end
