module Pulsedeck
  module Views
    class TestPage < Phlex::HTML
      def view_template
        render Components::Layout.new do
          h1 { "Pulsedeck" }
          div(class: "panels") do
            render(Components::Panel.new(title: "CPU temperature")) { plain "42 °C" }
            render(Components::Panel.new(title: "GPU power")) { plain "85 W" }
            render(Components::Panel.new(title: "Fan speed")) { plain "1200 RPM" }
          end
        end
      end
    end
  end
end
