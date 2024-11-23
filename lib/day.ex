defmodule AdventOfCode.Day do
  @callback part1(String.t()) :: any()
  @callback part2(String.t()) :: any()

  @spec solve(module :: module(), input :: String.t()) :: :ok
  def solve(module, input) do
    input = input |> String.trim() |> String.split("\n")
    run_part(module, :part1, input)
    run_part(module, :part2, input)
    :ok
  end

  @spec run_part(module :: module(), part :: atom(), input :: String.t()) :: :ok
  defp run_part(module, part, input) do
    {time, result} = :timer.tc(fn -> apply(module, part, [input]) end)
    IO.puts("#{part |> Atom.to_string() |> String.capitalize()}: #{result} (#{time / 1000} ms)")
    :ok
  end
end
