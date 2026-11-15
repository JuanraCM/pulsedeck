module Pulsedeck
  module Components
    class Panel < Phlex::HTML
      def initialize(title:)
        @title = title
        super()
      end

      def view_template(&)
        section(class: "panel", style: "border: 1px solid #444; border-radius: 8px; padding: 1rem; min-width: 12rem;") do
          h2(style: "margin: 0 0 0.5rem; font-size: 1rem;") { @title }
          div(class: "panel-body", &)
        end
      end
    end
  end
end
