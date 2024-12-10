defmodule AdventOfCode2024.Day10 do
  @behaviour AdventOfCode.Day

  use Memoize

  defmemo get_score(grid, start, part2) do
    h = Grid.get(grid, start)

    if h == 9 do
      if part2, do: 1, else: MapSet.new([start])
    else
      Grid.get_neighbours(grid, start)
      |> Enum.filter(fn pos -> Grid.get(grid, pos) == h + 1 end)
      |> Enum.map(&get_score(grid, &1, part2))
      |> then(
        &if part2,
          do: Enum.sum(&1),
          else: Enum.reduce(&1, MapSet.new(), fn s1, s2 -> MapSet.union(s1, s2) end)
      )
    end
  end

  def solve(input, part2) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Grid.strings_to_integer_grid()

    Grid.all_cells(grid)
    |> Enum.filter(fn pos -> Grid.get(grid, pos) == 0 end)
    |> Enum.map(&get_score(grid, &1, part2))
    |> Enum.map(&if part2, do: &1, else: MapSet.size(&1))
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
