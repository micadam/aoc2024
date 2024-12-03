defmodule GenericDay do
  @spec solve(module :: module(), parts :: [atom()], test :: boolean(), input_per_part :: boolean()) ::
          :ok
  def solve(module, parts, test, input_per_part) do
    IO.puts(
      "#{IO.ANSI.green()}🎄Day #{module |> Module.split() |> List.last() |> String.slice(-2..-1)}🎄#{IO.ANSI.reset()}"
    )

    input =
      if not input_per_part do
        InputReader.read_input(module, nil, test, input_per_part)
      else
        ""
      end

    cond do
      Enum.empty?(parts) ->
        IO.puts("#{IO.ANSI.red()}No parts implemented!#{IO.ANSI.reset()}")

      true ->
        parts
        |> Enum.each(fn part ->
          part_input = if input_per_part, do: InputReader.read_input(module, part, test, input_per_part), else: input
          run_part(module, part, part_input)
        end)
    end

    :ok
  end

  @spec run_part(module :: module(), part :: atom(), input :: String.t()) :: :ok
  defp run_part(module, part, input) do
    if input == "" do
      IO.puts("#{IO.ANSI.red()}No input provided!#{IO.ANSI.reset()}")
    else
      {time, result} = :timer.tc(fn -> apply(module, part, [input]) end)
      IO.puts("#{part |> Atom.to_string() |> String.capitalize()}: #{result} (#{time / 1000} ms)")
    end
    :ok
  end
end

defmodule AdventOfCode.Day do
  @callback part1(String.t()) :: any()
  @callback part2(String.t()) :: any()

  @spec solve(atom(), boolean()) :: :ok
  def solve(module, test) do
    parts = [:part1, :part2]
    GenericDay.solve(module, parts, test, false)
  end

  def input_per_part do
    false
  end
end

defmodule EverybodyCodes.Day do
  @callback part1(String.t()) :: any()
  @callback part2(String.t()) :: any()
  @callback part3(String.t()) :: any()

  def solve(module, test) do
    parts = [:part1, :part2, :part3]
    GenericDay.solve(module, parts, test, true)
  end
end
