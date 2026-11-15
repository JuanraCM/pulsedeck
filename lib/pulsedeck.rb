# typed: strict
# frozen_string_literal: true

require 'sinatra/base'
require 'phlex'
require 'sorbet-runtime'

require_relative 'pulsedeck/hwmon'
require_relative 'pulsedeck/providers/base'
require_relative 'pulsedeck/providers/cpu_temperature'
require_relative 'pulsedeck/components/layout'
require_relative 'pulsedeck/components/panel'
require_relative 'pulsedeck/views/test_page'
require_relative 'pulsedeck/app'
