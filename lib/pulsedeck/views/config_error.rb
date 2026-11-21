# typed: true
# frozen_string_literal: true

module Pulsedeck
  module Views
    # Page for an invalid config file. It reloads itself, so the dashboard returns when the file is valid.
    # typed: true because the Phlex HTML DSL is generated at runtime.
    class ConfigError < Phlex::HTML
      extend T::Sig

      RETRY_SECONDS = 3

      sig { params(message: String).void }
      def initialize(message:)
        @message = message
        super()
      end

      sig { void }
      def view_template
        render Components::Layout.new(refresh: RETRY_SECONDS) do
          pre(class: 'error') { @message }
        end
      end
    end
  end
end
