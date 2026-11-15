# typed: strict
# frozen_string_literal: true

module Pulsedeck
  # Reads values from the Linux hwmon sysfs tree.
  module Hwmon
    extend T::Sig

    ROOT = '/sys/class/hwmon'

    sig { params(driver: String, file: String).returns(T.nilable(Integer)) }
    def self.read_integer(driver:, file:)
      device = find_device(driver)
      return nil unless device

      Integer(File.read(File.join(device, file)).strip, exception: false)
    rescue SystemCallError
      nil
    end

    # Device numbers (hwmonN) change at boot, so find the device by its name file.
    sig { params(driver: String).returns(T.nilable(String)) }
    def self.find_device(driver)
      Dir.glob(File.join(ROOT, 'hwmon*')).find { |dir| driver_name(dir) == driver }
    end

    sig { params(dir: String).returns(T.nilable(String)) }
    def self.driver_name(dir)
      File.read(File.join(dir, 'name')).strip
    rescue SystemCallError
      nil
    end
    private_class_method :driver_name
    private_class_method :find_device
  end
end
