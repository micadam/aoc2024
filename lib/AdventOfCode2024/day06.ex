defmodule AdventOfCode2024.Day06 do
  @behaviour AdventOfCode.Day


  def walk_grid(grid) do
    start_pos =
      Grid.all_cells(grid)
      |> Enum.find(fn {row, col} -> Grid.get(grid, {row, col}) == "^" end)

    start_dir = {-1, 0}

    next_dir = %{
      {0, -1} => {-1, 0},
      {-1, 0} => {0, 1},
      {0, 1} => {1, 0},
      {1, 0} => {0, -1}
    }

    Stream.iterate({start_pos, start_dir, MapSet.new(), MapSet.new()}, fn {pos = {row, col}, dir = {drow, dcol},
                                                             visited, visited_with_dir} ->
      if MapSet.member?(visited_with_dir, {pos, dir}) do
        {:halt, :loop}
      else
        visited = MapSet.put(visited, pos)
        visited_with_dir = MapSet.put(visited_with_dir, {pos, dir})
        next_pos = {row + drow, col + dcol}

        if not Grid.is_valid_position(grid, next_pos) do
          {:halt, MapSet.size(visited)}
        else
          if Grid.get(grid, next_pos) == "#" do
            {pos, elem(Map.fetch(next_dir, dir), 1), visited, visited_with_dir}
          else
            {next_pos, dir, visited, visited_with_dir}
          end
        end
      end
      end)
      |> Enum.find(fn
        {:halt, _} -> true
        _ -> false
      end)
      |> elem(1)

  end
  @impl AdventOfCode.Day
  def part1(input) do
    grid =
      String.split(input, "\n", trim: true)
      |> Grid.strings_to_grid()

    walk_grid(grid)
  end

  @impl AdventOfCode.Day
  def part2(input) do
    grid = String.split(input, "\n", trim: true) |> Grid.strings_to_grid()
    # This is disgusting lol yolo
    Grid.all_cells(grid)
    |> Enum.map(fn pos = {row, col} ->
      c = Grid.get(grid, {row, col})
      if c == "#" or c == "^" do
        false
      else
        grid = Grid.set(grid, pos, "#")
        walk_grid(grid) == :loop
      end
    end)
    |> Enum.count(& &1)
  end
end
