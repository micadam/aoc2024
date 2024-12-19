defmodule AdventOfCode2024.Day19 do
  @behaviour AdventOfCode.Day

  use Memoize

  def preprocess(input) do
    [pieces, towels] = String.split(input, "\n\n", trim: true)

    pieces = String.split(pieces, ", ", trim: true)
    towels = String.split(towels, "\n", trim: true)

    {pieces, towels}
  end

  defmemo possible("", _), do: 1
  defmemo possible(towel, pieces) do
    pieces
      |> Enum.filter(fn piece -> String.starts_with?(towel, piece) end)
      |> Enum.map(fn piece -> possible(String.slice(towel, String.length(piece)..-1//1), pieces) end)
      |> Enum.sum()
  end

  @impl AdventOfCode.Day
  def part1(input) do
    {pieces, towels} = preprocess(input)

    towels
    |> Enum.map(fn towel ->
      possible(towel, pieces)
    end)
    |> Enum.count(& &1 > 0)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    {pieces, towels} = preprocess(input)

    towels
    |> Enum.map(fn towel ->
      possible(towel, pieces)
    end)
    |> Enum.sum()
  end
end
