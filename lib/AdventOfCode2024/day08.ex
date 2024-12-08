defmodule AdventOfCode2024.Day08 do
  @behaviour AdventOfCode.Day

  def preprocess(input) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Grid.strings_to_grid()

    positions =
      grid
      |> Grid.all_cells()
      |> Enum.map(fn pos -> {pos, Grid.get(grid, pos)} end)
      |> Enum.filter(fn {_, cell} -> cell != "." end)
      |> Enum.group_by(fn {_, cell} -> cell end)
      |> Enum.map(fn {_, l} -> Enum.map(l, fn {pos, _} -> pos end) end)

    {grid, positions}
  end

  @impl AdventOfCode.Day
  def part1(input) do
    {grid, positions} = preprocess(input)

    positions
    |> Enum.map(fn coordd_set ->
      coordd_set
      |> Iter.pairs()
      |> Enum.map(fn {{x1, y1}, {x2, y2}} ->
        dx = x2 - x1
        dy = y2 - y1

        [{x2 + dx, y2 + dy}, {x1 - dx, y1 - dy}]
      end)
      |> List.flatten()
    end)
    |> List.flatten()
    |> Enum.filter(fn {x, y} -> Grid.is_valid_position(grid, {x, y}) end)
    |> Enum.uniq()
    |> Enum.count()
  end

  @impl AdventOfCode.Day
  def part2(input) do
    {grid, positions} = preprocess(input)

    positions
    |> Enum.map(fn coordd_set ->
      coordd_set
      |> Iter.pairs()
      |> Enum.map(fn {a = {x1, y1}, b = {x2, y2}} ->
        dx = x2 - x1
        dy = y2 - y1

        Enum.map([{a, -1}, {b, 1}], fn {{xx, yy}, sign} ->
          Enum.reduce_while(0..1_000_000, [], fn i, acc ->
            pos = {xx + sign * i * dx, yy + sign * i * dy}

            if Grid.is_valid_position(grid, pos) do
              {:cont, [pos | acc]}
            else
              {:halt, acc}
            end
          end)
        end)
        |> List.flatten()
      end)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()
  end
end
