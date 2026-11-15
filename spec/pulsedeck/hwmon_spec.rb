# typed: false
# frozen_string_literal: true

RSpec.describe Pulsedeck::Hwmon do
  let(:result) { described_class.read_integer(driver: 'k10temp', file: 'temp1_input') }

  it 'finds the device by name and not by number' do
    add_hwmon_device(1, 'nvme', 'temp1_input' => '1000')
    add_hwmon_device(7, 'k10temp', 'temp1_input' => '47250')
    expect(result).to eq(47_250)
  end

  it 'uses the first device in sorted order when names repeat' do
    add_hwmon_device(2, 'k10temp', 'temp1_input' => '2000')
    add_hwmon_device(1, 'k10temp', 'temp1_input' => '1000')
    expect(result).to eq(1000)
  end

  it 'returns nil when the driver is not found' do
    add_hwmon_device(1, 'nvme', 'temp1_input' => '1000')
    expect(result).to be_nil
  end

  it 'returns nil when the file is not found' do
    add_hwmon_device(1, 'k10temp')
    expect(result).to be_nil
  end

  it 'returns nil when the content is not an integer' do
    add_hwmon_device(1, 'k10temp', 'temp1_input' => 'abc')
    expect(result).to be_nil
  end

  it 'returns nil when the root does not exist' do
    stub_const('Pulsedeck::Hwmon::ROOT', '/nonexistent')
    expect(result).to be_nil
  end
end
