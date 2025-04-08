defmodule MinerProvision.GenericMiner do
  def setup(), do: nil
  def start_mining(_args), do: nil
  def get_summary(), do: %MinerProvision.HashrateSummary{}
end
