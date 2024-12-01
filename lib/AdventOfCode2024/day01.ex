defmodule AdventOfCode2024.Day01 do
  @behaviour AdventOfCode.Day

  def preprocess(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn pair ->
      String.split(pair)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  @impl AdventOfCode.Day
  def part1(input) do
    input
    |> preprocess()
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip()
    |> Enum.map(fn {a, b} -> abs(a - b) end)
    |> Enum.sum()
  end

  @impl AdventOfCode.Day
  def part2(input) do
    input
    |> preprocess()
    |> then(fn [left, right] ->
      [
        left,
        Enum.frequencies(right)
      ]
    end)
    |> then(fn [left, map] -> Enum.map(left, fn x -> x * Map.get(map, x, 0) end) end)
    |> Enum.sum()
  end
end
