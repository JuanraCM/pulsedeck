# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Views
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class Dashboard < Phlex::HTML
      extend T::Sig

      sig { void }
      def view_template
        render Components::Layout.new do
          h1 { 'Pulsedeck' }
          div(class: 'panels') do
            render Components::ValueWidget.new(provider: Providers::CpuTemperature.new)
          end
        end
      end
    end
  end
end
