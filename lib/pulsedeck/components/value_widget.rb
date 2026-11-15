# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Components
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class ValueWidget < Phlex::HTML
      extend T::Sig

      sig { params(provider: Providers::Base).void }
      def initialize(provider:)
        @provider = provider
        super()
      end

      sig { void }
      def view_template
        value = @provider.value
        render(Panel.new(title: @provider.label)) do
          span(class: 'value', data: { metric: @provider.id, unit: @provider.unit }) do
            value.nil? ? 'N/A' : "#{value} #{@provider.unit}"
          end
        end
      end
    end
  end
end
