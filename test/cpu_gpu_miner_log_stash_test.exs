defmodule CpuGpuSentry.LogStashTest  do
  use ExUnit.Case
  alias MinerProvision.HashrateSummary

  test "update_hashrate_summary/1" do
    hashrate_summary = %HashrateSummary{
      cpu_hashrate: 1, cpu_hashrate_uom: "H/s",

      gpu_1_hashrate_1: 11, gpu_2_hashrate_1: 12,
      gpu_3_hashrate_1: 13, gpu_4_hashrate_1: 14,
      gpu_5_hashrate_1: 15, gpu_6_hashrate_1: 16,
      gpu_7_hashrate_1: 17, gpu_8_hashrate_1: 18,

      gpu_1_hashrate_2: 21, gpu_2_hashrate_2: 22,
      gpu_3_hashrate_2: 23, gpu_4_hashrate_2: 24,
      gpu_5_hashrate_2: 25, gpu_6_hashrate_2: 26,
      gpu_7_hashrate_2: 27, gpu_8_hashrate_2: 28,
      gpu_hashrate_uom_1: "KH/s", gpu_hashrate_uom_2: "GH/s"
    }

    CpuGpuSentry.LogStash.update_hashrate_summary(hashrate_summary)
    test_result = CpuGpuSentry.LogStash.get()
    expected_result = %CpuGpuSentry.LogStash.State{
      cpu_hashrate: 1, cpu_hashrate_uom: "H/s",

      gpu_1_hashrate_1: 11, gpu_2_hashrate_1: 12,
      gpu_3_hashrate_1: 13, gpu_4_hashrate_1: 14,
      gpu_5_hashrate_1: 15, gpu_6_hashrate_1: 16,
      gpu_7_hashrate_1: 17, gpu_8_hashrate_1: 18,

      gpu_1_hashrate_2: 21, gpu_2_hashrate_2: 22,
      gpu_3_hashrate_2: 23, gpu_4_hashrate_2: 24,
      gpu_5_hashrate_2: 25, gpu_6_hashrate_2: 26,
      gpu_7_hashrate_2: 27, gpu_8_hashrate_2: 28,
      gpu_hashrate_uom_1: "KH/s", gpu_hashrate_uom_2: "GH/s"
    }

    assert test_result == expected_result
  end
end
