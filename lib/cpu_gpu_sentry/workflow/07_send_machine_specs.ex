defmodule CpuGpuSentry.Workflow.SendMachineSpecs do
  def execute() do

  end

  def parse_motherboard_name(lscpu_output) do
    lscpu_output_map = Jason.decode!(lscpu_output)
    lscpu_output_map
    |> Map.get("lscpu")
    |> Enum.at(2)
    |> Map.get("children")
    |> Enum.at(0)
    |> Map.get("data")
  end
end
