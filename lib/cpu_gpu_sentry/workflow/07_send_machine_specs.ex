defmodule CpuGpuSentry.Workflow.SendMachineSpecs do
  def execute() do

  end

  @doc """
  parse_motherboard_name/1 do parse json output from `lscpu -J` command
  """
  def parse_motherboard_name(lscpu_output) do
    lscpu_output_map = Jason.decode!(lscpu_output)
    lscpu_output_map
    |> Map.get("lscpu")
    |> Enum.at(2)
    |> Map.get("children")
    |> Enum.at(0)
    |> Map.get("data")
  end

  @doc """
  parse_ram_size/1 do parse json output from `free -g` command
  """
  def parse_ram_size(free_output) do
    memory_in_gb = free_output
    |> String.split("\n")
    |> Enum.at(1)
    |> String.split()
    |> Enum.at(1)
    "#{memory_in_gb}GB"
  end

end
