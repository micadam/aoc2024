defmodule AdventOfCode2024.Day07 do
  @behaviour AdventOfCode.Day

  def preprocess(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn s ->
      String.split(s, ": ")
      |> then(fn [a, rest] ->
        [String.to_integer(a), String.split(rest) |> Enum.map(&String.to_integer/1)]
      end)
    end)
  end

  def concatenate_integers(a, b) do
    (Integer.digits(a) ++ Integer.digits(b))
    |> Enum.reduce(0, fn x, acc -> acc * 10 + x end)
  end

  def possible(target, acc, rest, concatenate \\ false) do
    case rest do
      [] ->
        acc == target

      [h | t] ->
        possible(target, acc + h, t, concatenate) or
          possible(target, acc * h, t, concatenate) or
          (concatenate and possible(target, concatenate_integers(acc, h), t, concatenate))
    end
  end

  def solve(input, concatenate) do
    input
    |> preprocess()
    |> Enum.filter(fn [target, rest] -> possible(target, 0, rest, concatenate) end)
    |> Enum.map(fn [target, _] -> target end)
    |> Enum.sum()
  end

  @impl AdventOfCode.Day
  def part1(input) do
    solve(input, false)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    solve(input, true)
  end
end

defmodule AdventOfCode2024.Day7Test do
  use ExUnit.Case, async: true

  test "concatenate numbers" do
    assert AdventOfCode2024.Day07.concatenate_integers(1, 2) == 12
    assert AdventOfCode2024.Day07.concatenate_integers(123456, 789) == 123456789
  end
end
