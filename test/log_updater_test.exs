defmodule CpuGpuSentry.LogUpdaterTest do
  use ExUnit.Case

  test "parse_lan_ip" do
    string = "8.8.8.8 via 192.168.0.1 dev eno1 src 192.168.0.103 uid 1000 \    cache "
    test_result = CpuGpuSentry.LogUpdater.parse_lan_ip(string)
    expected_result = "192.168.0.103"
    assert test_result == expected_result
  end

end
