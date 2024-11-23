defmodule AdventCLI do
  def main() do
    args = System.argv()
    main(args)
  end

  def main(args) do
    {opts, [day], _} =
      OptionParser.parse(args, switches: [test: :boolean, file: :string])

    if day do
      run_day(day, opts)
    else
      IO.puts("Please specify a day number")
    end
  end

  defp run_day(day, opts) do
    day = String.pad_leading(day, 2, "0")
    test_flag = opts[:test]

    input_file =
      if opts[:file] do
        opts[:file]
      else
        if test_flag do
          "input_test/day#{day}.txt"
        else
          "input/day#{day}.txt"
        end
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
