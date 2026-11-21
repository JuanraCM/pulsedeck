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
        .panel {
          container-type: size; min-width: 0; min-height: 0; overflow: hidden; padding: var(--gap);
          background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius);
        }
        .panel-title { margin: 0 0 0.5rem; font-size: 1rem; color: var(--muted); }
        .value { font-size: clamp(1rem, 22cqmin, 8rem); font-weight: bold; }
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
