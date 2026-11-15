module Pulsedeck
  module Components
    class Layout < Phlex::HTML
      CSS = <<~CSS
        body { margin: 0; padding: 1rem; background: #111; color: #eee; font-family: sans-serif; }
        h1 { margin-top: 0; }
        .panels { display: flex; gap: 1rem; flex-wrap: wrap; }
      CSS

      def view_template(&)
        doctype
        html do
          head do
            meta(charset: "utf-8")
            meta(name: "viewport", content: "width=device-width, initial-scale=1")
            title { "Pulsedeck" }
            style { raw safe(CSS) }
          end
          body(&)
        end
      end
    end
  end
end
