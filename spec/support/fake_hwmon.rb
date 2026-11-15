# typed: false
# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

# Points Pulsedeck::Hwmon::ROOT at an empty temporary directory for each example,
# so specs never read the real /sys tree.
module FakeHwmon
  def hwmon_root
    @hwmon_root
  end

  def add_hwmon_device(number, name, files = {})
    dir = File.join(@hwmon_root, "hwmon#{number}")
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, 'name'), "#{name}\n")
    files.each { |file, content| File.write(File.join(dir, file), content) }
  end

  def self.setup(example_group)
    example_group.before do
      @hwmon_root = Dir.mktmpdir
      stub_const('Pulsedeck::Hwmon::ROOT', @hwmon_root)
    end
    example_group.after { FileUtils.remove_entry(@hwmon_root) }
  end
end
