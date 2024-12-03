defmodule AdventOfCode2024.Day03 do
  @behaviour AdventOfCode.Day

  @impl AdventOfCode.Day
  def part1(input) do
    Regex.scan(~r/mul\(([0-9]+),([0-9]+)\)/, input)
    |> Enum.map(fn [_, a, b] -> String.to_integer(a) * String.to_integer(b) end)
    |> Enum.sum()
  end

  @impl AdventOfCode.Day
  def part2(input) do
    Regex.scan(~r/(do|don't|mul)\((?:([0-9]+),([0-9]+))?\)/, input)
    |> Enum.reduce({0, :do}, fn
      [_, "mul", a, b], {acc, :do} -> {acc + String.to_integer(a) * String.to_integer(b), :do}
      [_, "mul" | _], {acc, :dont} -> {acc, :dont}
      [_, "do" | _], {acc, _} -> {acc, :do}
      [_, "don't" | _], {acc, _} -> {acc, :dont}
    end)
    |> elem(0)
  end
end
