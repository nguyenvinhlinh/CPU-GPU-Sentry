defmodule CpuGpuSentry.LogUpdaterTest do
  use ExUnit.Case

  test "parse_lan_ip" do
    string = "8.8.8.8 via 192.168.0.1 dev eno1 src 192.168.0.103 uid 1000 \    cache "
    test_result = CpuGpuSentry.LogUpdater.parse_lan_ip(string)
    expected_result = "192.168.0.103"
    assert test_result == expected_result
  end

  test "parse_cpu_temp_type_1" do
    cmd_output = File.read!("./test/test_assets/sensors-1.json")
    sensor_cmd_output_map = Jason.decode!(cmd_output)
    test_result = CpuGpuSentry.LogUpdater.parse_cpu_temp_type_1(sensor_cmd_output_map)
    expected_result = 70
    assert test_result == expected_result
  end

  test "parse_cpu_temp 1" do
    cmd_output = File.read!("./test/test_assets/sensors-1.json")
    test_result = CpuGpuSentry.LogUpdater.parse_cpu_temp(cmd_output)
    expected_result = 70
    assert test_result == expected_result
  end

  test "parse_cpu_temp_type_2" do
    cmd_output = File.read!("./test/test_assets/sensors-2.json")
    sensor_cmd_output_map = Jason.decode!(cmd_output)
    test_result = CpuGpuSentry.LogUpdater.parse_cpu_temp_type_2(sensor_cmd_output_map)
    expected_result = 85
    assert test_result == expected_result
  end

  test "parse_cpu_temp 2" do
    cmd_output = File.read!("./test/test_assets/sensors-2.json")
    test_result = CpuGpuSentry.LogUpdater.parse_cpu_temp(cmd_output)
    expected_result = 85
    assert test_result == expected_result
  end
end
