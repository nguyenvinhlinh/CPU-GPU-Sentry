defmodule CpuGpuSentry.SystemDataTest do
  use ExUnit.Case
  alias CpuGpuSentry.SystemData

  test "parse_lan_ip" do
    string = "8.8.8.8 via 192.168.0.1 dev eno1 src 192.168.0.103 uid 1000 \    cache "
    test_result = SystemData.parse_lan_ip(string)
    expected_result = "192.168.0.103"
    assert test_result == expected_result
  end

  test "parse_cpu_temp_type_1" do
    cmd_output = File.read!("./test/test_assets/sensors-1.json")
    sensor_cmd_output_map = Jason.decode!(cmd_output)
    test_result = SystemData.parse_cpu_temp_type_1(sensor_cmd_output_map)
    expected_result = 70
    assert test_result == expected_result
  end

  test "parse_cpu_temp 1" do
    cmd_output = File.read!("./test/test_assets/sensors-1.json")
    test_result = SystemData.parse_cpu_temp(cmd_output)
    expected_result = 70
    assert test_result == expected_result
  end

  test "parse_cpu_temp_type_2" do
    cmd_output = File.read!("./test/test_assets/sensors-2.json")
    sensor_cmd_output_map = Jason.decode!(cmd_output)
    test_result = SystemData.parse_cpu_temp_type_2(sensor_cmd_output_map)
    expected_result = 85
    assert test_result == expected_result
  end

  test "parse_cpu_temp 2" do
    cmd_output = File.read!("./test/test_assets/sensors-2.json")
    test_result = SystemData.parse_cpu_temp(cmd_output)
    expected_result = 85
    assert test_result == expected_result
  end

  test "parse_gpu_data 1" do
    cmd_output = File.read!("./test/test_assets/nvidia_smi_gpu_temp_fan_power-1.csv")
    test_result = SystemData.parse_gpu_data(cmd_output)

    expected_result = %{
      gpu_1_core_temp: 63, gpu_2_core_temp: 65, gpu_3_core_temp: 67,
      gpu_1_mem_temp: nil, gpu_2_mem_temp: nil, gpu_3_mem_temp: nil,
      gpu_1_core_clock: 1833, gpu_2_core_clock: 1835, gpu_3_core_clock: 1837,
      gpu_1_mem_clock: 9503, gpu_2_mem_clock: 9505, gpu_3_mem_clock: 9507,
      gpu_fan_uom: "%",
      gpu_1_fan: 33, gpu_2_fan: 35, gpu_3_fan: 37,
      gpu_1_power: 104, gpu_2_power: 106, gpu_3_power: 108
    }
    assert test_result == expected_result
  end

  test "parse_gpu_data 2" do
    cmd_output = File.read!("./test/test_assets/nvidia_smi_gpu_temp_fan_power-2.csv")
    test_result = SystemData.parse_gpu_data(cmd_output)

    expected_result = %{gpu_fan_uom: "%"}
    assert test_result == expected_result
  end

  test "is_command_exist? 1" do
    command = "sh"
    test_result = SystemData.is_command_exist?(command)
    expected_result = true
    assert test_result == expected_result
  end

  test "is_command_exist? 2" do
    command = "bad_command"
    test_result = SystemData.is_command_exist?(command)
    expected_result = false
    assert test_result == expected_result
  end
end
