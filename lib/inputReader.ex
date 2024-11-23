defmodule InputReader do
  @spec read_input(module(), atom(), boolean, boolean) :: String.t()
  def read_input(day, part, test, input_per_part) do
    [_, pack, day] = day |> Atom.to_string() |> String.split(".")
    filename = if input_per_part, do: "#{day}#{part}.txt", else: "#{day}.txt"

    input_file =
      if test,
        do: "inputs/#{pack}/input_test/#{filename}",
        else: "inputs/#{pack}/input/#{filename}"

    case File.read(input_file) do
      {:ok, input} ->
        input

      {:error, reason} ->
        IO.puts("Error reading input #{input_file}: #{reason}")
        ""
    end
  end
end
