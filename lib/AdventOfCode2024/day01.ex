defmodule AdventOfCode2024.Day01 do
  @behaviour AdventOfCode.Day

  @impl AdventOfCode.Day
  def part1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(&Kernel.+/2)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(&Kernel.*/2)
  end
end
