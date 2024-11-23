defmodule AdventCLI do
  def main() do
    args = System.argv()
    main(args)
  end

  def main(args) do
    {opts, days, _} =
      OptionParser.parse(args, switches: [test: :boolean, file: :string, pack: :string])

    pack = opts[:pack] || "AdventOfCode2024"
    run_day_partial = fn day -> run_day(day, pack, opts) end

    if Enum.any?(days) do
      Enum.each(days, run_day_partial)
    else
      IO.puts("Please specify a day number")
    end
  end

  defp run_day(day, pack, opts) do
    day = String.pad_leading(day, 2, "0")
    test_flag = opts[:test]
    day_module = "Elixir.#{pack |> String.slice(0..-5//1)
    }.Day" |> String.to_atom()

    module = String.to_atom("Elixir.#{pack}.Day#{day}")
    apply(day_module, :solve, [module, test_flag])
  end
end
