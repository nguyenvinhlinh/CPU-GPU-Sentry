defmodule MinerProvision.XMRIG_6_22_2Test do
  use ExUnit.Case

  alias MinerProvision.XMRIG_6_22_2

  test "parse_xmrig_summary" do
    json_string = File.read!("./test/miner_provision/xmrig_2_summary.json")
    test_result = XMRIG_6_22_2.parse_xmrig_summary(json_string)
    expected_result = %{
      cpu_hashrate_uom: "H/s",
      cpu_hashrate: 9564
    }

    assert test_result == expected_result
  end

end
