defmodule AdventOfCode2024.Day02 do
  @behaviour AdventOfCode.Day

  def safe_part_1(sequence) do
    sequence
    |> Enum.chunk_every(2, 1, :discard)
    |> then(fn pairs ->
      Enum.all?(pairs, fn [a, b] -> a - b >= 1 and a - b <= 3 end) or
        Enum.all?(pairs, fn [a, b] -> b - a >= 1 and b - a <= 3 end)
    end)
  end

  def solve(input, pred) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn s ->
      String.split(s)
      |> Enum.map(&String.to_integer/1)
      |> pred.()
    end)
    |> IO.inspect()
    |> Enum.count(& &1)
  end

  @impl AdventOfCode.Day
  def part1(input) do
    input
    |> solve(&safe_part_1/1)
  end

  def omit(enum, index) do
    enum
    |> Enum.with_index()
    |> Enum.reject(fn {_elem, idx} -> idx == index end)
    |> Enum.map(fn {elem, _idx} -> elem end)
  end

  def safe_part_2(sequence) do
    safe_part_1(sequence) or
      Enum.any?(0..(Enum.count(sequence) - 1), fn i ->
        sequence
        |> omit(i)
        |> safe_part_1()
      end)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    input |> solve(&safe_part_2/1)
  end
end
