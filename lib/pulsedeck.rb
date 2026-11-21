# typed: strict
# frozen_string_literal: true

require 'json'
require 'yaml'
require 'fileutils'
require 'sinatra/base'
require 'phlex'
require 'sorbet-runtime'

require_relative 'pulsedeck/hwmon'
require_relative 'pulsedeck/providers/base'
require_relative 'pulsedeck/providers/cpu_temperature'
require_relative 'pulsedeck/event_stream'
require_relative 'pulsedeck/placement'
require_relative 'pulsedeck/components/layout'
require_relative 'pulsedeck/components/grid'
require_relative 'pulsedeck/components/panel'
require_relative 'pulsedeck/components/value_widget'
require_relative 'pulsedeck/views/dashboard'
require_relative 'pulsedeck/config'
require_relative 'pulsedeck/app'
