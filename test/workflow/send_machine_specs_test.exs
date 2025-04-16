defmodule CpuGpuSentry.Workflow.SendMachineSpecsTest do
  use ExUnit.Case
  alias CpuGpuSentry.Workflow.SendMachineSpecs

  test "parse_cpu_name" do
    lscpu_output = File.read!("./test/workflow/lscpu.json")

    test_result = SendMachineSpecs.parse_cpu_name(lscpu_output)
    expected_result = "Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz"
    assert test_result == expected_result
  end

  test "parse_ram_size" do
    free_output = File.read!("./test/workflow/free-g.txt")
    test_result = SendMachineSpecs.parse_ram_size(free_output)
    expected_result = "125GB"
    assert test_result == expected_result
  end

  test "parse_gpu_map_nvidia" do
    nvidia_smi_output = File.read!("./test/workflow/nvidia-smi.txt")
    test_result = SendMachineSpecs.parse_gpu_map(nvidia_smi_output, :nvidia)
    expected_result = %{
      gpu_1_name: "NVIDIA GeForce RTX 3080"
    }

    assert test_result == expected_result
  end
end
