defmodule AdventOfCode2024.Day04 do
  @behaviour AdventOfCode.Day

  @impl AdventOfCode.Day
  def part1(input) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Grid.strings_to_grid()

    for {row, col} <- Grid.all_cells(grid),
        {drow, dcol} <- [
          {0, 1},
          {0, -1},
          {1, 0},
          {-1, 0},
          {1, 1},
          {1, -1},
          {-1, 1},
          {-1, -1}
        ] do
      word =
        Enum.reduce(0..3, "", fn i, acc ->
          {nrow, ncol} = {row + i * drow, col + i * dcol}

          if Grid.is_valid_position(grid, {nrow, ncol}) do
            acc <> Grid.get(grid, {nrow, ncol})
          else
            acc
          end
        end)

      word == "XMAS"
    end
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  @impl AdventOfCode.Day
  def part2(input) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Grid.strings_to_grid()

    Grid.all_cells(grid)
    |> Enum.map(fn {row, col} ->
      c = Grid.get(grid, {row, col})

      if c != "A" do
        false
      else
        diags = [[{-1, -1}, {1, 1}], [{-1, 1}, {1, -1}]]

        Enum.all?(diags, fn ds ->
          if Enum.any?(ds, fn {drow, dcol} ->
               not Grid.is_valid_position(grid, {row + drow, col + dcol})
             end) do
            false
          else
            Enum.map(ds, fn {drow, dcol} -> Grid.get(grid, {row + drow, col + dcol}) end)
            |> Enum.join()
            |> then(&(&1 == "MS" or &1 == "SM"))
          end
        end)
      end
    end)
    |> Enum.filter(& &1)
    |> Enum.count()
  end
end
