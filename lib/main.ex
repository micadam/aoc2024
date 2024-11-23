defmodule AdventCLI do
  def main() do
    args = System.argv()
    main(args)
  end

  def main(args) do
    {opts, days, _} =
      OptionParser.parse(args, switches: [test: :boolean, file: :string])

    run_day_partial = fn day -> run_day(day, opts) end

    if Enum.any?(days) do
      Enum.each(days, run_day_partial)
    else
      IO.puts("Please specify a day number")
    end
  end

  defp run_day(day, opts) do
    day = String.pad_leading(day, 2, "0")
    test_flag = opts[:test]

    input_file =
      cond do
        opts[:file] -> opts[:file]
        test_flag -> "input_test/day#{day}.txt"
        true -> "input/day#{day}.txt"
      end

    case File.read(input_file) do
      {:ok, input} ->
        module = String.to_atom("Elixir.AdventOfCode.Day#{day}")
        AdventOfCode.Day.solve(module, input)

      {:error, reason} ->
        case reason do
          :enoent -> IO.puts("Input file not found: #{input_file}")
          _ -> IO.puts("Error reading input file #{input_file}: #{reason}")
        end
    end
  end
end
