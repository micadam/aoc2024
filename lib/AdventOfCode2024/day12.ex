defmodule AdventOfCode2024.Day12 do
  @behaviour AdventOfCode.Day

  defp get_regions(input) do
    # This is just a normal BFS but I suck at Elixir so it looks ugly
    grid =
      input
      |> String.split("\n", trim: true)
      |> Grid.strings_to_grid()

    grid
    |> Grid.all_cells()
    |> Enum.reduce({[], MapSet.new()}, fn
      pos, {plots, visited} ->
        if MapSet.member?(visited, pos) do
          {plots, visited}
        else
          symbol = Grid.get(grid, pos)
          queue = :queue.from_list([pos])

          {plot, visited} =
            Stream.iterate({:cont, {queue, {0, MapSet.new()}, visited}}, fn
              {_, {queue, plot = {perimeter, cells}, visited}} ->
                {v, queue} = :queue.out(queue)

                case v do
                  :empty ->
                    {:halt, {plot, visited}}

                  {:value, pos = {row, col}} ->
                    if MapSet.member?(visited, pos) do
                      {:cont, {queue, plot, visited}}
                    else
                      visited = MapSet.put(visited, pos)

                      {queue, perimeter} =
                        Enum.reduce(
                          [{0, 1}, {1, 0}, {0, -1}, {-1, 0}],
                          {queue, perimeter},
                          fn {drow, dcol}, {queue, perimeter} ->
                            npos = {row + drow, col + dcol}

                            if Grid.is_valid_position(grid, npos) and
                                 Grid.get(grid, npos) == symbol do
                              if not MapSet.member?(visited, npos) do
                                {:queue.in(npos, queue), perimeter}
                              else
                                {queue, perimeter}
                              end
                            else
                              {queue, perimeter + 1}
                            end
                          end
                        )

                      {:cont, {queue, {perimeter, MapSet.put(cells, pos)}, visited}}
                    end
                end
            end)
            |> Enum.find(fn {signal, _} -> signal == :halt end)
            |> elem(1)

          {[plot | plots], visited}
        end
    end)
    |> elem(0)
  end

  @impl AdventOfCode.Day
  def part1(input) do
    get_regions(input)
    |> Enum.map(fn {perimeter, cells} -> perimeter * Enum.count(cells) end)
    |> Enum.sum()
  end

  defp get_boundaries(pos = {row, col}, grid, dirs) do
    dirs
    |> Enum.map(fn {drow, dcol, dir} ->
      {{row + drow, col + dcol}, dir}
    end)
    |> Enum.filter(fn {npos, _} ->
      not Grid.is_valid_position(grid, npos) or Grid.get(grid, pos) != Grid.get(grid, npos)
    end)
    |> Enum.map(fn {_, dir} -> {pos, dir} end)
  end

  defp get_horizontal_boundaries(pos, grid) do
    get_boundaries(pos, grid, [{-1, 0, :up}, {1, 0, :down}])
  end

  defp get_vertical_boundaries(pos, grid) do
    get_boundaries(pos, grid, [{0, -1, :left}, {0, 1, :right}])
  end

  @impl AdventOfCode.Day
  def part2(input) do
    grid =
      input
      |> String.split("\n", trim: true)
      |> Grid.strings_to_grid()

    get_regions(input)
    |> Enum.map(fn {_, cells} ->
      num_vertical_edges =
        cells
        |> Enum.map(fn cell -> get_vertical_boundaries(cell, grid) end)
        |> List.flatten()
        |> Enum.sort(fn {{row1, col1}, dir1}, {{row2, col2}, dir2} ->
          {col1, dir1, row1} < {col2, dir2, row2}
        end)
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.reduce(1, fn [{{row1, col1}, dir1}, {{row2, col2}, dir2}], acc ->
          if col1 != col2 or row2 - row1 != 1 or dir1 != dir2 do
            acc + 1
          else
            acc
          end
        end)

      num_horizontal_edges =
        cells
        |> Enum.map(fn cell -> get_horizontal_boundaries(cell, grid) end)
        |> List.flatten()
        |> Enum.sort(fn {{row1, col1}, dir1}, {{row2, col2}, dir2} ->
          {row1, dir1, col1} < {row2, dir2, col2}
        end)
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.reduce(1, fn [{{row1, col1}, dir1}, {{row2, col2}, dir2}], acc ->
          if row1 != row2 or col2 - col1 != 1 or dir1 != dir2 do
            acc + 1
          else
            acc
          end
        end)

      (num_horizontal_edges + num_vertical_edges) * Enum.count(cells)
    end)
    |> Enum.sum()
  end
end
