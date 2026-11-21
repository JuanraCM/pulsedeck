# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Layout < Phlex::HTML
      extend T::Sig

      CSS = <<~CSS
        :root {
          --gap: 0.75rem; --radius: 8px; --surface: #1b1b1b; --border: #444; --text: #eee; --muted: #999;
        }
        * { box-sizing: border-box; }
        body {
          margin: 0; padding: var(--gap); height: 100vh; display: flex; flex-direction: column; overflow: hidden;
          background: #111; color: var(--text); font-family: sans-serif;
        }
        .grid { flex: 1; min-height: 0; display: grid; gap: var(--gap); }
        .error { margin: 0; white-space: pre-wrap; color: #f88; }
        .panel {
          container-type: size; min-width: 0; min-height: 0; overflow: hidden; padding: var(--gap);
          background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius);
        }
        .panel-title { margin: 0 0 0.5rem; font-size: 1rem; color: var(--muted); }
        .value { font-size: clamp(1rem, 22cqmin, 8rem); font-weight: bold; }
      CSS

      # refresh: seconds after which the browser reloads the page. Nil means never.
      sig { params(refresh: T.nilable(Integer)).void }
      def initialize(refresh: nil)
        @refresh = refresh
        super()
      end

      sig { params(block: T.proc.void).void }
      def view_template(&block)
        doctype
        html do
          head { head_tags }
          body(&block)
        end
      end

      private

      sig { void }
      def head_tags
        meta(charset: 'utf-8')
        refresh_tag
        meta(name: 'viewport', content: 'width=device-width, initial-scale=1')
        title { 'Pulsedeck' }
        style { raw safe(CSS) }
      end

      # Phlex marks http-equiv as unsafe, so the value is given as `safe`. It is a fixed string.
      sig { void }
      def refresh_tag
        meta('http-equiv': safe('refresh'), content: @refresh.to_s) if @refresh
      end
    end
  end
end
