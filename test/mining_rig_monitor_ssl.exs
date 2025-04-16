defmodule CpuGpuSentry.MiningRigMonitorSSLTest do
  use ExUnit.Case

  # This is not a test, it's a note about bypass selfsign CA & Certificate
  # Error:
  # {:tls_alert, {:handshake_failure, ~c"TLS client: In state wait_cert_cr at ssl_handshake.erl:2176 generated CLIENT ALERT: Fatal - Handshake Failure\n {bad_cert,hostname_check_failed}"}
  # {:server_name_indication, :disable} or {:server_name_indication, ~c"mrm.hexalink.xyz" } helps it.

  test "access to mrm.hexalink.xyz 1" do
    url = "https://mrm.hexalink.xyz/users/log_in"
    header_list = []
    option_list = [
      {:ssl,  [
          {:versions, [:"tlsv1.2", :"tlsv1.3"]},
          {:verify, :verify_peer},
          {:cacertfile, "./test/test_assets/Nguyen_Vinh_Linh-CA.pem"},
          {:depth, 10},
          {:server_name_indication, ~c"mrm.hexalink.xyz" },
          {:customize_hostname_check,
           [
             match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
           ]}
        ]}
    ]
    http_postion_get_output = HTTPoison.get(url, header_list, option_list)

    test_status = http_postion_get_output
    |> Kernel.elem(0)
    expected_result = :ok
    assert(test_status == expected_result)

    test_http_status_code  = http_postion_get_output
    |> Kernel.elem(1)
    |> Map.get(:status_code)
    expected_http_status_code = 200

    assert(test_http_status_code == expected_http_status_code)
  end
end
