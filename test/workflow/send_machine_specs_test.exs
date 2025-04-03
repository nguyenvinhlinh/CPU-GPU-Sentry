defmodule CpuGpuSentry.Workflow.SendMachineSpecsTest do
  use ExUnit.Case
  alias CpuGpuSentry.Workflow.SendMachineSpecs

  test "parse_motherboard_name" do
    lscpu_output = File.read!("./test/workflow/lscpu.json")

    test_result = SendMachineSpecs.parse_motherboard_name(lscpu_output)
    expected_result = "Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz"
    assert test_result == expected_result
  end

end
