defmodule AdventOfCode2024.Day11 do
  @behaviour AdventOfCode.Day
  use Memoize

  def split_in_half(number) do
    s = Integer.to_string(number)
    slice_len = div(String.length(s), 2)

    [
      String.to_integer(String.slice(s, 0, slice_len)),
      String.to_integer(String.slice(s, slice_len, slice_len))
    ]
  end

  defmemo(split_stones([], _), do: 0)
  defmemo(split_stones([_ | rest], 0), do: 1 + split_stones(rest, 0))

  defmemo split_stones([s1 | rest], splits) do
    split_stone(s1, splits) + split_stones(rest, splits)
  end

  defmemo(split_stone(_, 0), do: 1)
  defmemo(split_stone(0, splits), do: split_stone(1, splits - 1))

  defmemo split_stone(stone, splits) do
    string_len = stone |> Integer.to_string() |> String.length()

    if rem(string_len, 2) == 0 do
      split_stones(split_in_half(stone), splits - 1)
    else
      split_stone(stone * 2024, splits - 1)
    end
  end

  def solve(input, splits) do
    stones =
      input
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    split_stones(stones, splits)
  end

  @impl AdventOfCode.Day
  def part1(input) do
    solve(input, 25)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    solve(input, 75)
  end
end
